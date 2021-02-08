{
  name: 'VITAL (Revenue)',
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
    Continent: {
      model: 'firebase_event_in_app_purchase',
      dimension: 'continent',
      required: false,
    },
    'Install Source': {
      model: 'firebase_event_in_app_purchase',
      dimension: 'install_source',
      required: false,
    },
    Version: {
      model: 'firebase_event_in_app_purchase',
      dimension: 'version',
      required: false,
    },
    Platform: {
      model: 'firebase_event_in_app_purchase',
      dimension: 'platform',
      required: false,
    },
  },
  reports: [{
    name: 'Revenue',
    x: 0,
    y: 0,
    height: 2,
    width: 6,
    component: 'r-table',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['revenue_from_new_users', 'revenue_from_retained_users', 'revenue_from_whales', 'revenue_whales_ratio', 'revenue'],
      dimensions: [{
        name: 'event_timestamp',
        timeframe: 'day',
      }],
      reportOptions: {
        chartOptions: {
          type: null,
        },
      },
      limit: 1000,
    },
  }, {
    name: 'Revenue Conversion',
    x: 0,
    y: 2,
    height: 2,
    width: 6,
    component: 'r-table',
    type: 'segmentation',
    options: {
      model: 'firebase_event_in_app_purchase',
      measures: ['average_transaction_per_paying_user', 'transaction_count_per_paying_user'],
      dimensions: [{
        name: 'event_timestamp',
        timeframe: 'day',
      }],
      reportOptions: {
        chartOptions: {
          type: null,
        },
      },
      limit: 1000,
    },
  }],
}
