var util = require('mis-util');
var config = require('./config.ignore');

var options = {
   sysname: config.sysname,
   webname: config.webname,
   connect: {
      host: config.host,
      user: config.name,
      password: config.user
   },
   cron: {
      user: config.cronname,
      pass: config.cron
   },
   view_path: {
      local: './view/',
      remote: '/CUST/forms/'
   },
   parm_path: {
      local: './build/'
   },
   usc_path: {
      local: './uScript/'
   }
};

var mis = util(options);

mis.script.install('usc/service_obj.usc')
.then(mis.script.install.bind(mis, 'usc/nf-event-summary.usc'))
.then(mis.script.install.bind(mis, 'usc/lib_clientevents.usc'))
.then(mis.parm.fromflatfile.bind(mis, 'parm/snssumry.parm'))
.then(mis.parm.tofile.bind(mis, 'build/SNSSUMRY.parm'))
.then(mis.deploy.parm)
