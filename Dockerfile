FROM bmya/odoo10
MAINTAINER Blanco Martín & Asociados <daniel@blancomartin.cl>
# install some dependencies
USER root

# Generate locale (es_AR for right odoo es_AR language config, and C.UTF-8 for postgres and general locale data)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y locales -qq
RUN echo 'es_AR.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'es_CL.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'es_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'C.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN dpkg-reconfigure locales && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8


# Install some deps
# adds slqalchemy
RUN apt-get update && apt-get install -y python-pip \
                                         git \
                                         vim \
                                         ghostscript \
                                         python-dev \
                                         freetds-dev \
                                         python-gevent \
                                         python-matplotlib \
                                         font-manager \
                                         libxml2-dev \
                                         libxslt-dev \
                                         lib32z1-dev \
                                         liblz-dev \
                                         swig \
                                         libssl-dev \
                                         libcups2-dev \
                                         sudo

RUN mkdir /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 600 -R /root/.ssh
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

# odoo argentina (nuevo modulo de FE).
RUN apt-get install -y swig libffi-dev libssl-dev python-m2crypto python-httplib2 mercurial

RUN git clone https://github.com/bmya/pyafipws-1.git /pyafipws
WORKDIR /pyafipws/
ADD ./requirements.txt /pyafipws/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN python setup.py install
RUN chmod 777 -R /usr/local/lib/python2.7/dist-packages/PyAfipWs-2.7.0-py2.7.egg/

# create directories for repos
RUN mkdir -p /opt/odoo/stable-addons/oca
RUN mkdir -p /opt/odoo/stable-addons/bmya/odoo-chile
RUN mkdir -p /opt/odoo/.filelocal/odoo
RUN mkdir -p /var/lib/odoo/backups/synced

# update openerp-server.conf file (todo: edit with "sed")
COPY ./odoo.conf /etc/odoo/
RUN chown odoo /etc/odoo/odoo.conf
RUN chmod 644 /etc/odoo/odoo.conf
RUN chown -R odoo /opt/odoo
RUN chown -R odoo /opt/odoo/stable-addons
RUN chown -R odoo /mnt/extra-addons
RUN chown -R odoo /var/lib/odoo
# RUN chown -R odoo /mnt/filelocal/odoo

# Instalación de repositorios varios BMyA
WORKDIR /opt/odoo/stable-addons/bmya/
RUN git clone -b 10.0 https://github.com/Danisan/odoo-telegram.git
WORKDIR odoo-telegram/
RUN pip install -r requirements.txt
WORKDIR /opt/odoo/stable-addons/bmya/
# Reemplaza a Odoo Addons
# RUN git clone -b 10.0 https://github.com/bmya/sale.git
# RUN git clone -b 10.0 https://github.com/bmya/product.git
# RUN git clone -b 10.0 https://github.com/bmya/survey.git
# RUN git clone -b 10.0 https://github.com/bmya/account-financial-tools.git
# RUN git clone -b 10.0 https://github.com/bmya/partner.git
# RUN git clone -b 10.0 https://github.com/bmya/stock.git
# RUN git clone -b bmya_custom_10.0 https://github.com/bmya/odoo-support.git
# RUN git clone -b 10.0 https://github.com/bmya/project.git
# RUN git clone -b 10.0 https://github.com/bmya/adhoc-project.git
# RUN git clone -b 10.0 https://github.com/bmya/account-payment.git
# RUN git clone -b 10.0 https://github.com/bmya/account-invoicing.git
# RUN git clone -b 10.0 https://github.com/bmya/website.git
# RUN git clone -b 10.0 https://github.com/bmya/odoo-web.git
# RUN git clone -b 10.0 https://github.com/bmya/multi-company.git
# RUN git clone -b 10.0 https://github.com/bmya/account-analytic.git
# RUN git clone -b 10.0 https://github.com/bmya/purchase.git
RUN git clone -b 10.0 https://github.com/bmya/reporting-engine.git
RUN git clone -b 10.0 https://github.com/bmya/crm.git
# RUN git clone -b 10.0 https://github.com/bmya/adhoc-crm.git
# RUN git clone -b 10.0 https://github.com/bmya/miscellaneous.git
# RUN git clone -b 10.0 https://github.com/bmya/surveyor.git
# RUN git clone -b 10.0 https://github.com/bmya/odoo-logistic.git

# Modulos de OCA
RUN git clone -b 10.0 https://github.com/OCA/server-tools.git
RUN git clone -b 10.0 https://github.com/OCA/margin-analysis.git
RUN git clone -b 10.0 https://github.com/OCA/product-attribute.git

# RUN git clone -b 10.0 https://github.com/OCA/pos-addons.git
# RUN git clone -b 10.0 https://github.com/OCA/pos.git

# Localización Argentina
# RUN git clone -b 10.0 https://github.com/ingadhoc/odoo-argentina.git

# Localización Chilena (Con Factura Electrónica LibreDTE)
# RUN git clone -b 10.0 https://github.com/bmya/odoo-bmya-cl.git
RUN mkdir -p /mnt/extra-addons
WORKDIR /mnt/extra-addons
RUN mkdir odoo-chile
WORKDIR odoo-chile
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_dte.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_invoice.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_counties.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_partner_activities.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_dte_caf.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_base.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_base_rut.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_vat.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/webservices_generic.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_financial_indicators.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_clear_translation.git
# RUN git clone -b 10.0 git@github.com:odoo-chile/l10n_cl_account_vat_ledger.git
WORKDIR /opt/odoo/extra-addons
# RUN git clone -b 10.0 git@github.com:bmya/odoo-bmya.git


# Otras dependencias de BMyA
# RUN git clone -b 10.0 https://github.com/bmya/odoo-bmya.git
# RUN git clone -b 10.0 https://github.com/bmya/website-addons.git

# RUN git clone -b 10.0 https://github.com/bmya/odoo-single-adv.git
# RUN git clone -b bmya_custom https://github.com/bmya/tkobr-addons.git tko
# RUN git clone https://github.com/bmya/addons-yelizariev.git
# RUN git clone https://github.com/bmya/ws-zilinkas.git

WORKDIR /opt/odoo/stable-addons/bmya/odoo-chile/
WORKDIR /opt/odoo/stable-addons/bmya/
# RUN git clone -b 10.0 git@bitbucket.org:hdblanco/odoo-chl-tr.git
# RUN git clone -b 10.0 https://github.com/odoo-chile/l10n_cl_vat.git
# RUN git clone -b 10.0 https://github.com/odoo-chile/base_state_ubication.git
# RUN git clone -b 10.0 https://github.com/odoo-chile/decimal_precision_currency.git
# RUN git clone -b 10.0 https://github.com/odoo-chile/invoice_printed.git

WORKDIR /opt/odoo/stable-addons/oca/
RUN git clone -b 10.0 https://github.com/OCA/knowledge.git
RUN git clone -b 10.0 https://github.com/OCA/web.git
RUN git clone -b 10.0 https://github.com/OCA/bank-statement-reconcile.git
RUN git clone -b 10.0 https://github.com/OCA/account-invoicing.git

RUN chown -R odoo:odoo /opt/odoo/stable-addons
WORKDIR /opt/odoo/stable-addons/
# RUN git clone -b 10.0 https://github.com/aeroo/aeroo_reports.git

## Clean apt-get (copied from odoo)
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make auto_install = False for various modules
# RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python2.7/dist-packages/odoo/addons/im_chat/__manifest__.py
# RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python2.7/dist-packages/odoo/addons/im_odoo_support/__manifest__.py
RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python2.7/dist-packages/odoo/addons/bus/__manifest__.py
RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python2.7/dist-packages/odoo/addons/base_import/__manifest__.py
RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python2.7/dist-packages/odoo/addons/portal/__manifest__.py
# RUN sed  -i  "s/'auto_install': False/'auto_install': True/" /opt/odoo/stable-addons/bmya/addons-yelizariev/web_logo/__manifest__.py

# Change default aeroo host name to match docker name
# RUN sed  -i  "s/localhost/aeroo/" /opt/odoo/stable-addons/aeroo_reports/report_aeroo/docs_client_lib.py
# RUN sed  -i  "s/localhost/aeroo/" /opt/odoo/stable-addons/aeroo_reports/report_aeroo/installer.py
# RUN sed  -i  "s/localhost/aeroo/" /opt/odoo/stable-addons/aeroo_reports/report_aeroo/report_aeroo.py

USER odoo
