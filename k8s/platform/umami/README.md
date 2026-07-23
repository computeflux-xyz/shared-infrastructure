# Umami analytics

Minimal self-hosted [Umami](https://umami.is) on the shared cluster.

- **Deployment**: single `umami` pod in `platform`, image
  `ghcr.io/umami-software/umami:postgresql-latest`, served at the container root.
- **Database**: dedicated CloudNativePG cluster `umami-pg-cluster` (1 instance).
  `DATABASE_URL` comes from the operator-generated `umami-pg-cluster-app` secret
  (`uri` key, namespace-qualified host).
- **Backups**: WAL archiving + a daily `ScheduledBackup` to
  `s3://computeflux-db-backups/umami/`, 30 day retention. S3 credentials reuse
  the platform `zot-s3-credentials` secret (same Hetzner keys).
- **Exposure**: the API gateway publishes only three paths, mapping the public
  `/push-analytics/...` prefix down to the app root with an nginx rewrite:
  `/push-analytics/script.js`, `/push-analytics/api/send`, `/push-analytics/api/batch`.
  The dashboard, `/login` and admin APIs have no public route.

`BASE_PATH` is intentionally not set: it is a build-time variable in Umami, so it
has no effect on the prebuilt image. The subpath is produced entirely by the
gateway rewrite (`k8s/platform/api-gateway/ingress.yaml`).

## Embed the tracker

`data-host-url` is required so the tracker posts events to the public subpath
(not to the site's own origin):

```html
<script defer
        src="https://apigateway.computeflux.xyz/push-analytics/script.js"
        data-website-id="YOUR-WEBSITE-ID"
        data-host-url="https://apigateway.computeflux.xyz/push-analytics"></script>
```

The tracker then sends to `.../push-analytics/api/send` (and `/api/batch`), the
only collector paths the gateway exposes.

## Reach the dashboard (admin, internal only)

```bash
kubectl -n platform port-forward svc/umami 3000:3000
# open http://localhost:3000  (default login admin / umami)
```

Change the default password immediately. Create your website there to get the
`data-website-id`.

## Optional: stable APP_SECRET

```bash
cd ../.. && task seal:secret
#   name:      umami-app-secret
#   namespace: platform
#   key:       app-secret
#   value:     generate
#   output:    shared/secrets/umami-app-secret.sealed.yaml
kubectl apply -f shared/secrets/umami-app-secret.sealed.yaml
kubectl -n platform rollout restart deployment/umami
```
