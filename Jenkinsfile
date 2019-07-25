#!groovy

@Library('freeagent') _

freeagentGem(
    node: 'smartos',
    slack: [channel: '#tax-eng-ci'],
    remote:        "https://rubygems.org/api/v1/gems",
    key:           "rubygems_api_key",
    pushTag:       true,
    forcePush:     true )
