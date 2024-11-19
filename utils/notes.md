# Notes

## Grafana

`WSID=$(tofu output -raw grafana_workspace_id)`

Get API key

```bash
#!/bin/bash

WSID=$(tofu output -raw grafana_workspace_id)
aws grafana create-workspace-api-key \
    --workspace-id $WSID \
    --key-name "my-api-key" \
    --key-role ADMIN \
    --seconds-to-live 86400 | jq -r '.key'
```

PPL for dashboard

```ppl
source = sensor-data-index-*
| sort -timestamp
| dedup city
| fields city, company, coordinates.latitude, coordinates.longitude, health
```

List data sources

```bash
curl -H "Authorization: Bearer 12345678901" \
     -H "Content-Type: application/json" \
     https://g-8a6f655f40.grafana-workspace.us-east-1.amazonaws.com/api/datasources
```

Get a datasource

```bash
curl -H "Authorization: Bearer eyJrI12345678901" \
     -H "Content-Type: application/json" \
     https://g-8a6f655f40.grafana-workspace.us-east-1.amazonaws.com/api/datasources/3
```

Datasource JSON

```bash
{
  "id": 3,
  "uid": "ae35d82fvgsn4b",
  "orgId": 1,
  "name": "OpenSearch 12345678901/sdt",
  "type": "grafana-opensearch-datasource",
  "typeLogoUrl": "public/plugins/grafana-opensearch-datasource/img/logo.svg",
  "access": "proxy",
  "url": "https://search-sdt-7763precxqvo4nbmg45k5t3bum.us-east-1.es.amazonaws.com",
  "user": "",
  "database": "",
  "basicAuth": false,
  "basicAuthUser": "",
  "withCredentials": false,
  "isDefault": true,
  "jsonData": {
    "database": "sensor-data-index-*",
    "flavor": "opensearch",
    "logLevelField": "",
    "logMessageField": "",
    "maxConcurrentShardRequests": 5,
    "pplEnabled": true,
    "provisionedBy": "aws-datasource-provisioner-app",
    "serverless": false,
    "sigV4Auth": true,
    "sigV4AuthType": "ec2_iam_role",
    "sigV4Region": "us-east-1",
    "timeField": "timestamp",
    "timeout": 60,
    "version": "1.0.0",
    "versionLabel": "OpenSearch 1.0.0"
  },
  "secureJsonFields": {},
  "version": 19,
  "readOnly": false
}
```

Panel JSON

```json
{
  "datasource": {
    "type": "grafana-opensearch-datasource",
    "uid": "ae35d82fvgsn4b"
  },
  "description": "",
  "fieldConfig": {
    "defaults": {
      "custom": {
        "hideFrom": {
          "tooltip": false,
          "viz": false,
          "legend": false
        }
      },
      "mappings": [],
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {
            "color": "green",
            "value": null
          },
          {
            "color": "dark-red",
            "value": 1
          }
        ]
      },
      "color": {
        "mode": "thresholds"
      }
    },
    "overrides": []
  },
  "gridPos": {
    "h": 22,
    "w": 24,
    "x": 0,
    "y": 0
  },
  "hideTimeOverride": true,
  "id": 1,
  "options": {
    "view": {
      "allLayers": true,
      "id": "coords",
      "lat": 39.383246,
      "lon": -94.684591,
      "zoom": 4.92
    },
    "controls": {
      "showZoom": true,
      "mouseWheelZoom": true,
      "showAttribution": false,
      "showScale": false,
      "showMeasure": false,
      "showDebug": false
    },
    "tooltip": {
      "mode": "details"
    },
    "basemap": {
      "config": {},
      "name": "Layer 0",
      "type": "default"
    },
    "layers": [
      {
        "config": {
          "showLegend": true,
          "style": {
            "color": {
              "field": "health",
              "fixed": "dark-green"
            },
            "opacity": 1,
            "rotation": {
              "fixed": 0,
              "max": 360,
              "min": -360,
              "mode": "mod"
            },
            "size": {
              "fixed": 5,
              "max": 15,
              "min": 2
            },
            "symbol": {
              "fixed": "img/icons/marker/circle.svg",
              "mode": "fixed"
            },
            "symbolAlign": {
              "horizontal": "center",
              "vertical": "center"
            },
            "text": {
              "field": "company",
              "fixed": "",
              "mode": "fixed"
            },
            "textConfig": {
              "fontSize": 12,
              "offsetX": 10,
              "offsetY": 0,
              "textAlign": "left",
              "textBaseline": "middle"
            }
          }
        },
        "filterData": {
          "id": "byRefId",
          "options": "health"
        },
        "location": {
          "latitude": "coordinates.latitude",
          "longitude": "coordinates.longitude",
          "mode": "coords"
        },
        "name": "health",
        "tooltip": true,
        "type": "markers"
      }
    ]
  },
  "pluginVersion": "10.4.1",
  "targets": [
    {
      "alias": "",
      "bucketAggs": [
        {
          "field": "timestamp",
          "id": "2",
          "settings": {
            "interval": "auto"
          },
          "type": "date_histogram"
        }
      ],
      "datasource": {
        "type": "grafana-opensearch-datasource",
        "uid": "ae35d82fvgsn4b"
      },
      "format": "table",
      "metrics": [
        {
          "id": "1",
          "type": "count"
        }
      ],
      "query": "source = sensor-data-index-*\n| sort -timestamp\n| dedup city\n| fields city, company, coordinates.latitude, coordinates.longitude, health",
      "queryType": "PPL",
      "refId": "health",
      "timeField": "timestamp"
    }
  ],
  "timeFrom": "5m",
  "timeShift": "5m",
  "title": "Health Metrics",
  "transformations": [
    {
      "id": "convertFieldType",
      "options": {
        "conversions": [
          {
            "destinationType": "number",
            "targetField": "health"
          },
          {
            "destinationType": "number",
            "targetField": "coordinates.latitude"
          },
          {
            "destinationType": "number",
            "targetField": "coordinates.longitude"
          }
        ],
        "fields": {}
      }
    }
  ],
  "type": "geomap"
}
```

Panel Data JSON

```json
{
  "state": "Error",
  "series": [],
  "request": {
    "app": "dashboard",
    "requestId": "Q1015",
    "timezone": "browser",
    "panelId": 1,
    "panelPluginId": "geomap",
    "dashboardUID": "be358iofx5ddsc",
    "range": {
      "from": "2024-11-07T04:08:59.144Z",
      "to": "2024-11-07T04:13:59.144Z",
      "raw": {
        "from": "2024-11-07T04:08:59.144Z",
        "to": "2024-11-07T04:13:59.144Z"
      }
    },
    "timeInfo": "",
    "interval": "200ms",
    "intervalMs": 200,
    "targets": [
      {
        "alias": "",
        "bucketAggs": [
          {
            "field": "timestamp",
            "id": "2",
            "settings": {
              "interval": "auto"
            },
            "type": "date_histogram"
          }
        ],
        "datasource": {
          "type": "grafana-opensearch-datasource",
          "uid": "ae35d82fvgsn4b"
        },
        "format": "table",
        "metrics": [
          {
            "id": "1",
            "type": "count"
          }
        ],
        "query": "source = sensor-data-index-*\n| sort -timestamp\n| dedup city\n| fields city, company, coordinates.latitude, coordinates.longitude, health",
        "queryType": "PPL",
        "refId": "health",
        "timeField": "timestamp"
      }
    ],
    "maxDataPoints": 1395,
    "scopedVars": {
      "__interval": {
        "text": "200ms",
        "value": "200ms"
      },
      "__interval_ms": {
        "text": "200",
        "value": 200
      }
    },
    "startTime": 1730953139144,
    "filters": []
  },
  "error": {},
  "timings": {
    "dataProcessingTime": 0
  },
  "structureRev": 1
}
```

## OpenSearch

Get some documents from index

```bash
curl -X GET "https://search-sdt-7763precxqvo4nbmg45k5t3bum.us-east-1.es.amazonaws.com/sensor-data-index-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": 1000,
  "query": {
    "match_all": {}
  }
}
' | jq 
```

Get index retention policy

```bash
curl -X GET "https://search-sdt-7763precxqvo4nbmg45k5t3bum.us-east-1.es.amazonaws.com/_plugins/_ism/policies/one-day-retention-policy" -H 'Content-Type: application/json' | jq
```

Set index retention policy

```bash
curl -X PUT "https://search-sdt-7763precxqvo4nbmg45k5t3bum.us-east-1.es.amazonaws.com/_plugins/_ism/policies/one-day-retention-policy" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "description": "Policy to delete indexes older than one day",
    "default_state": "hot",
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [
          {
            "state_name": "delete",
            "conditions": {
              "min_index_age": "1d"
            }
          }
        ]
      },
      {
        "name": "delete",
        "actions": [
          {
            "delete": {}
          }
        ]
      }
    ],
    "ism_template": {
      "index_patterns": ["sensor-data-index*"],
      "priority": 100
    }
  }
}'
```

## Okta

Get Apps

```bash
curl -X GET "https://trial-6804569.okta.com/api/v1/apps" -H "Authorization: SSWS 008qHO3My6Nwh-biYHBy_HiRT8l4UBBmRI" -H "Accept: application/json"
```

Get App Definition

```bash
curl -X GET "https://trial-6804569.okta.com/api/v1/apps/0oal24c2nzmO600aK697" -H "Authorization: SSWS 008qHO3My6Nwh-biYHBy_HiRT8l4UBBmRI" -H "Accept: application/json"
```
