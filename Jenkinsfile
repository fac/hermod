#!groovy

@Library('freeagent@rubygem_publish') _

freeagentGem(
    node: 'webkit',
    slack: [channel: '#tax-eng-alerts'],
    remote:        "https://rubygems.org/api/v1/gems",
    key:           "rubygems_api_key",
    pushTag:       true,
    forcePush:     true )
