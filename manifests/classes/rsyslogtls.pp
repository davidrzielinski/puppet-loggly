class rsyslogtls::install inherits rsyslog::install{

  # TODO - clean up dependencies and test on other systems
  $rsyslogtlspkg = $operatingsystem ? {
    Fedora => "rsyslog-gnutls",
    CentOS => "rsyslog4-gnutls",
    default => "rsyslog-gnutls"
  }

  if $operatingsystem == "CentOS"{
    package {$rsyslogtlspkg :
      ensure => latest,
      alias => "rsyslog-gnutls",
      require => Yumrepo["ius"],
    }
  }else{
    package {$rsyslogtlspkg :
      ensure => latest,
      alias => "rsyslog-gnutls",
    }
  }
}
class rsyslogtls::config inherits rsyslog::config {  
  File {
    require => Class["rsyslogtls::install"],
    owner => "root",
    group => "root",
    mode => 644
  }

  $tlsconf = "tls.conf"
  $logglycrt = "/etc/loggly.com.crt"

  File[$rsyslogconf]{
    content => template("loggly/tls.conf.erb","loggly/rsyslog.conf.erb"),
  }
  
  file {$logglycrt :
    source => "puppet:///modules/loggly/loggly.com.crt"
  }
  
}


class rsyslogtls inherits rsyslog {
  include rsyslogtls::install, rsyslogtls::config
}
