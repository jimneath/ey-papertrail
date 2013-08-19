default[:papertrail] = {
  :gem_version => '~>1.6',
  :version => '3.3.5-r1',
  :port => 44618,
  :hostname => ['app_name', node[:instance_role], `hostname`.chomp].join('_'),
  :logs => [
    '/var/log/nginx/*log',
    '/data/app_name/shared/log/*log'
  ],
  :exclude => [
    '400 0 "-" "-" "-',
    '104: Connection reset by peer',
    'favicon.png',
    "/haproxy/monitor",
    '"SiteUptime.com"',
    '"NewRelicPinger"'
  ]
}