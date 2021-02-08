{
  name: 'Sales',
  category: 'Firebase',
  filters: {
    Date: {
      mappingDimension: 'eventTimestamp',
      default: 'P14D',
      required: true,
    },
    Country: {
      model: 'firebase_event_in_app_purchase',
      dimension: 'country',
      required: false,
    },
    'Install Source': {
      model: 'firebase_event_in_app_purchase',
      dimension: 'install_source',
      required: false,
    },
    'App Version': {
      model: 'firebase_event_in_app_purchase',
      dimension: 'version',
      required: false,
    },
    'Product ID': {
      model: 'firebase_event_in_app_purchase',
      dimension: 'event__product_id',
      required: false,
    },
    Platform: {
      model: 'firebase_event_in_app_purchase',
      dimension: 'platform',
      default: ['IOS'],
      required: false,
    },
  },
  reports: [{
    name: 'Daily sales per country',
    x: 0,
    y: 3,
    height: 2,
    width: 3,
    component: 'r-table',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['total_transactions'],
      dimensions: [{
        name: 'event_timestamp',
        timeframe: 'day',
      }, 'country'],
      filters: [{
        measure: 'total_transactions',
        operator: 'greaterThan',
        value: 1,
      }],
      reportOptions: {
        chartOptions: {
          type: 'area',
          showLabels: true,
          showLegend: false,
          interactive: true,
        },
      },
      limit: 5000,
    },
  }, {
    name: 'Most paying countries',
    x: 3,
    y: 3,
    height: 2,
    width: 3,
    component: 'r-chart',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['paying_users'],
      dimensions: ['country'],
      filters: [{
        measure: 'total_transactions',
        operator: 'greaterThan',
        value: 1,
      }],
      reportOptions: {
        chartOptions: {
          type: 'pie',
          showLabels: true,
          showLegend: false,
          showPercentage: true,
        },
      },
      limit: 5000,
    },
  }, {
    name: 'Total Sales (Retained Users)',
    x: 2,
    y: 0,
    height: 1,
    width: 2,
    component: 'r-number',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['revenue_from_retained_users'],
      reportOptions: {},
      limit: 5000,
    },
  }, {
    name: 'Total Sales',
    x: 0,
    y: 0,
    height: 1,
    width: 2,
    component: 'r-number',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['revenue'],
      reportOptions: {
        chartOptions: {
          type: null,
        },
      },
      limit: 5000,
    },
  }, {
    name: 'Total Sales (New Users)',
    x: 4,
    y: 0,
    height: 1,
    width: 2,
    component: 'r-number',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['revenue_from_new_users'],
      reportOptions: {
        chartOptions: {
          type: null,
        },
      },
      limit: 5000,
    },
  }, {
    name: 'Purchases HOD',
    x: 3,
    y: 1,
    height: 2,
    width: 3,
    component: 'r-chart',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['all_users'],
      dimensions: [{
        name: 'event_timestamp',
        timeframe: 'hour_of_day',
      }],
      reportOptions: {
        chartOptions: {
          type: 'bar',
          showLabels: true,
          showLegend: false,
          interactive: true,
        },
      },
      limit: 5000,
    },
  }, {
    name: 'Daily Purchases',
    x: 0,
    y: 1,
    height: 2,
    width: 3,
    component: 'r-chart',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['all_users'],
      dimensions: [{
        name: 'event_timestamp',
        timeframe: 'day',
      }, 'event__product_id'],
      reportOptions: {
        chartOptions: {
          type: 'area',
          showLabels: true,
          showLegend: true,
          interactive: true,
        },
      },
      limit: 5000,
    },
  }],
}
