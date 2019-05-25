

setpref('Internet','E_mail','damian.sutcliffe@yahoo.com');
setpref('Internet','SMTP_Server','smtp.mail.yahoo.com');
setpref('Internet','SMTP_Username','damian.sutcliffe@yahoo.com');
setpref('Internet','SMTP_Password','qrtfxfslvpnmigui');

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


sendmail({'damian.sutcliffe@yahoo.com'}, 'Hello From MATLAB!');