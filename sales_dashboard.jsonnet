{
  name: 'Sales',
  category: 'Firebase',
  filterSchema: {
    Date: {
      mappingDimension: 'eventTimestamp',
      default: 'P14D',
      required: true,
    },
    Country: {
      dimension: 'firebase_events.country',
      required: false,
    },
    Continent: {
      dimension: 'firebase_events.continent',
      required: false,
    },
    'Install Source': {
      dimension: 'firebase_events.install_source',
      required: false,
    },
    Version: {
      dimension: 'firebase_events.version',
      required: false,
    },
    Platform: {
      dimension: 'firebase_events.platform',
      required: false,
    },
  },
  reports: [
    {
      name: 'Daily sales per country',
      x: 0,
      y: 3,
      h: 2,
      w: 3,
      component: 'r-table',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day',
          },
          'firebase_event_in_app_purchase',
        ],
        measures: [
          'total_transactions',
        ],
        reportOptions: {
          chartOptions: {
            type: 'area',
            showLabels: true,
            showLegend: false,
            interactive: true,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 5000,
        filters: [
          {
            measure: 'total_transactions',
            operator: 'greaterThan',
            value: 1,
          },
        ],
        orders: null,
      },
    },
    {
      name: 'Most paying countries',
      x: 3,
      y: 3,
      h: 2,
      w: 3,
      component: 'r-chart',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: [
          'country',
        ],
        measures: [
          'paying_users',
        ],
        reportOptions: {
          chartOptions: {
            type: 'pie',
            showLabels: true,
            showLegend: false,
            columnOptions: [],
            showPercentage: true,
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 5000,
        filters: [
          {
            measure: 'total_transactions',
            operator: 'greaterThan',
            value: 1,
          },
        ],
        orders: null,
      },
    },
    {
      name: 'Total Sales (Retained Users)',
      x: 2,
      y: 0,
      h: 1,
      w: 2,
      component: 'r-number',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        measures: [
          'revenue_from_retained_users',
        ],
      },
    },
    {
      name: 'Total Sales',
      x: 0,
      y: 0,
      h: 1,
      w: 2,
      component: 'r-number',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: null,
        measures: [
          'revenue',
        ],
        reportOptions: {
          chartOptions: {
            type: null,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 5000,
        filters: null,
        orders: null,
      },
    },
    {
      name: 'Total Sales (New Users)',
      x: 4,
      y: 0,
      h: 1,
      w: 2,
      component: 'r-number',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: null,
        measures: [
          'revenue_from_new_users',
        ],
        reportOptions: {
          chartOptions: {
            type: null,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 5000,
        filters: null,
        orders: null,
      },
    },
    {
      name: 'Purchases HOD',
      ttl: 'PT24H',
      x: 3,
      y: 1,
      h: 2,
      w: 3,
      component: 'r-chart',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'hourOfDay',
          },
        ],
        measures: [
          'all_users',
        ],
        reportOptions: {
          chartOptions: {
            type: 'bar',
            showLabels: true,
            showLegend: false,
            interactive: true,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 5000,
        filters: null,
        orders: null,
      },
    },
    {
      name: 'Daily Purchases',
      ttl: 'PT24H',
      x: 0,
      y: 1,
      h: 2,
      w: 3,
      component: 'r-chart',
      type: 'segmentation',
      reportOptions: {
        model: 'firebase_event_in_app_purchase',
        dimensions: [
          {
            name: 'event_timestamp',
            timeframe: 'day',
          },
          'event__product_id',
        ],
        measures: [
          'all_users',
        ],
        reportOptions: {
          chartOptions: {
            type: 'area',
            showLabels: true,
            showLegend: true,
            interactive: true,
            columnOptions: [],
          },
          tableOptions: {
            columnOptions: [],
          },
          columnOptions: null,
        },
        limit: 5000,
        filters: null,
        orders: null,
      },
    },
  ],
}
