apache:
  pkg.installed:
    - pkgs:
       - httpd
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: apache 

apache-restart:
  module.wait:
    - name: service.restart
    - m_name: httpd

apache-reload:
  module.wait:
    - name: service.reload
    - m_name: httpd

sites-enabled:
  file.directory:
    - name: /etc/httpd/sites-enabled
    - user: apache
    - group: apache
    - mode: 755 

sites-available:
  file.directory:
      - name: /etc/httpd/sites-available
      - user: apache
      - group: apache
      - mode: 755

sites-available-config:
  file.blockreplace:
      - name: /etc/httpd/conf/httpd.conf
      - marker_start: '#BEGIN Managed by salt - do not edit'
      - marker_end: '#END Managed by salt - do not edit'
      - content: 'IncludeOptional sites-enabled/*.conf'
      - append_if_not_found: True
      - require:
        - pkg: apache

disable-default-site:
  file.absent:
    - name: /etc/httpd/sites-enabled/000-default
    - listen_in:
      - module: apache-reload

httpd_can_network_connect:
  selinux.boolean:
    - value: True
    - persist: True
 
a2enmod proxy:
  cmd.wait:
    - watch:
      - pkg: apache
    - listen_in:
      - module: apache-restart

a2enmod proxy_http:
  cmd.wait:
    - watch:
      - pkg: apache
    - listen_in:
      - module: apache-restart
