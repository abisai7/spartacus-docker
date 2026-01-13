# Spartacus Libraries Docker Registry

This Docker setup allows you to build and self-publish Spartacus libraries in a local Docker container using Verdaccio.

## Quick Start

### Using Docker Compose (Recommended)

1. **Build and start the container:**

   ```bash
   docker-compose up -d
   ```

2. **Check the logs:**

   ```bash
   docker-compose logs -f
   ```

3. **Access Verdaccio:**
   - Open your browser and navigate to: <http://localhost:4873>
   - You should see all published `@spartacus/*` packages including `@spartacus/schematics`

### Using Docker CLI

1. **Build the image:**

   ```bash
   docker build -t spartacus-verdaccio --build-arg SPARTACUS_VERSION="release/2211.43.x" .
   ```

2. **Run the container:**

   ```bash
   docker run -d -p 4873:4873 --name spartacus-registry spartacus-verdaccio
   ```

3. **View logs:**

   ```bash
   docker logs -f spartacus-registry
   ```

## Configuration

### Changing Spartacus Version

**Docker Compose:**
Edit `docker-compose.yml` and change the `SPARTACUS_VERSION` build argument:

```yaml
build:
  args:
    SPARTACUS_VERSION: "release/2211.43.x"  # Change to desired version
```

**Docker CLI:**

```bash
docker build -t spartacus-verdaccio --build-arg SPARTACUS_VERSION="release/2211.43.x" .
```

### Changing Node.js Version

Edit the `Dockerfile` and change the base image:

```dockerfile
FROM node:18-alpine  # Change to desired Node.js version
```

## Using the Published Libraries

### Published Packages

The following packages are built and published to the local Verdaccio registry:

**Core Libraries:**

- `@spartacus/core` - Core framework
- `@spartacus/storefrontlib` - Storefront components
- `@spartacus/assets` - i18n assets
- `@spartacus/styles` - Style library with global styles
- `@spartacus/schematics` - Angular schematics for automated setup

**Feature Libraries:**

- `@spartacus/asm` - Assisted Service Module
- `@spartacus/cart` - Cart functionality
- `@spartacus/checkout` - Checkout process
- `@spartacus/order` - Order management
- `@spartacus/product` - Product features
- `@spartacus/user` - User account features
- `@spartacus/organization` - Organization/B2B features
- `@spartacus/storefinder` - Store locator
- `@spartacus/tracking` - Analytics and tracking

**Integration Libraries:**

- `@spartacus/cdc` - Customer Data Cloud
- `@spartacus/cdp` - Customer Data Platform
- `@spartacus/cds` - Context-Driven Services
- `@spartacus/digital-payments` - Digital payment integrations
- `@spartacus/epd-visualization` - EPD Visualization
- `@spartacus/smartedit` - SmartEdit integration
- And many more...

### Configure npm to use the local registry

For Spartacus packages only:

**Bash/Linux/macOS:**

```bash
npm config set @spartacus:registry http://localhost:4873
```

**PowerShell (Windows):**

```powershell
npm config set "@spartacus:registry" "http://localhost:4873"
```

Or use `.npmrc` file in your project (Recommended - works on all platforms):

```
@spartacus:registry=http://localhost:4873
```

To create the `.npmrc` file automatically:

```bash
echo @spartacus:registry=http://localhost:4873 > .npmrc
```

### Create a new Spartacus application

**Important:** Before running `ng add`, you must create a `.npmrc` file in your project directory to ensure Angular CLI uses the local registry.

1. **Create a new Angular app:**

   ```bash
   ng new mystore --style=scss --routing=false --standalone=false
   cd mystore
   ```

2. **Create `.npmrc` file in your project:**

   **PowerShell (Windows):**

   ```powershell
   echo "@spartacus:registry=http://localhost:4873" | Out-File -FilePath .npmrc -Encoding utf8
   ```

   **Bash/Linux/macOS:**

   ```bash
   echo "@spartacus:registry=http://localhost:4873" > .npmrc
   ```

3. **Verify the correct version is available:**

   ```bash
   npm view @spartacus/schematics version
   ```

   This should show `2211.40.0` (or your installed version), not an older version from npmjs.org

4. **Add Spartacus to your application:**

   ```bash
   ng add @spartacus/schematics@~2211.43.0
   ```

5. Follow the prompts to set up your Spartacus application.

### Upgrade existing application

```bash
ng update @spartacus/schematics@6.0.0
```

## Management Commands

### Stop the container

```bash
docker-compose down
```

### Restart the container

```bash
docker-compose restart
```

### Remove everything (including volumes)

```bash
docker-compose down -v
```

### Rebuild after changes

```bash
docker-compose up -d --build
```

## Troubleshooting

### ng add installs wrong version

If `ng add @spartacus/schematics` tries to install an old version (like 2.1.9 instead of 2211.40.0):

1. Make sure you have a `.npmrc` file in your project directory (not globally)
2. Verify it contains: `@spartacus:registry=http://localhost:4873`
3. Check the version npm sees: `npm view @spartacus/schematics version`
4. If it still shows the wrong version, clear npm cache: `npm cache clean --force`

### Container won't start

Check the logs:

```bash
docker-compose logs
```

### Packages not appearing

Wait for the build process to complete (can take 5-10 minutes):

```bash
docker-compose logs -f
```

### Reset Verdaccio storage

```bash
docker-compose down -v
docker-compose up -d
```

## Production Deployment

This is intended for local development only. For production use, consider use of a hosted npm registry or a private npm repository solution.

[More about SAP Composable Storefront Libraries](https://help.sap.com/docs/SAP_COMMERCE_COMPOSABLE_STOREFRONT/cfcf687ce2544bba9799aa6c8314ecd0/5de67850bd8d487181fef9c9ba59a31d.html?locale=en-US#installing-composablestorefront-libraries-from-the-repository-based-shipment-channel)

## Resources

- [SAP Composable Storefront](https://help.sap.com/docs/SAP_COMMERCE_COMPOSABLE_STOREFRONT/cfcf687ce2544bba9799aa6c8314ecd0/3bbcccd2b5ea4aea8fa66e4a723bad76.html?locale=en-US/)
- [Verdaccio Documentation](https://verdaccio.org/docs/what-is-verdaccio)
- [Original Self-Publishing Guide](https://github.com/SAP/spartacus/blob/develop/docs/self-publishing-spartacus-libraries.md)
- [Spartacus GitHub Repository](https://github.com/SAP/spartacus)
