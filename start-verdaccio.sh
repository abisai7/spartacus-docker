#!/bin/bash

# Start Verdaccio in the background
verdaccio --config /verdaccio/conf/config.yaml &
VERDACCIO_PID=$!

# Wait for Verdaccio to start
echo "Waiting for Verdaccio to start..."
sleep 5

# Wait for Verdaccio to be ready (use IPv4 address)
until curl -f http://127.0.0.1:4873 > /dev/null 2>&1; do
  echo "Waiting for Verdaccio to be ready..."
  sleep 2
done
echo "Verdaccio is ready!"

# Force npm to use IPv4 (127.0.0.1) instead of IPv6 (::1)
# This prevents ECONNREFUSED errors
NPM_REGISTRY="http://127.0.0.1:4873"

# Create npmrc with auth token to bypass authentication
# This creates a base64 encoded auth token for user:pass = admin:admin
echo "//127.0.0.1:4873/:_authToken=\"Anonymous\"" > ~/.npmrc
echo "registry=${NPM_REGISTRY}" >> ~/.npmrc

# Alternative: Use expect to automate npm adduser
echo "Configuring npm user..."
cat > /tmp/adduser.sh << 'ADDUSER_EOF'
#!/usr/bin/expect -f
set timeout 10
spawn npm adduser --registry http://127.0.0.1:4873
expect "Username:"
send "admin\r"
expect "Password:"
send "admin\r"
expect "Email: (this IS public)"
send "admin@local.host\r"
expect eof
ADDUSER_EOF

# Try to add user with expect if available, otherwise continue without auth
if command -v expect &> /dev/null; then
  chmod +x /tmp/adduser.sh
  /tmp/adduser.sh || echo "Note: Could not auto-login, publishing may fail"
else
  echo "Note: expect not available, using token-based auth"
fi

# Build and publish Spartacus schematics
echo "Building @spartacus/schematics..."
cd /spartacus-build/projects/schematics
if npm run build 2>&1; then
  echo "Publishing @spartacus/schematics..."
  if npm publish --registry ${NPM_REGISTRY} 2>&1; then
    echo "Successfully published @spartacus/schematics"
  else
    echo "Warning: Failed to publish @spartacus/schematics"
  fi
else
  echo "Warning: Failed to build @spartacus/schematics"
fi

# Publish @spartacus/styles
echo "Publishing @spartacus/styles..."
cd /spartacus-build/projects/storefrontstyles
if npm publish --registry ${NPM_REGISTRY} 2>&1; then
  echo "Successfully published @spartacus/styles"
else
  echo "Warning: Failed to publish @spartacus/styles"
fi

# Publish Spartacus libraries to Verdaccio
echo "Publishing Spartacus libraries..."
cd /spartacus-build

# Publish each library
for lib in dist/*/package.json; do
  dir=$(dirname "$lib")
  echo "Publishing from $dir..."
  cd "$dir"
  
  # Try to publish with detailed error output
  if ! npm publish --registry ${NPM_REGISTRY} 2>&1; then
    echo "Warning: Failed to publish from $dir"
  else
    echo "Successfully published from $dir"
  fi
  
  cd /spartacus-build
done

# Reset registry and keep Verdaccio running
npm config set registry https://registry.npmjs.org/
echo ""
echo "========================================"
echo "Spartacus libraries published!"
echo "Verdaccio registry running at http://localhost:4873"
echo "========================================"
echo ""

# Keep container running
wait $VERDACCIO_PID
