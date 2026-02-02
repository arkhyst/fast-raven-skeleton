<?php if(!FastRaven\Services\AuthService::isAuthorized()): ?>
<button onclick="Lib.request('/api/autoauthorize', 'POST', {'check': '1234567890'}).then(function(res){
    if(res.success) window.location.reload(); else alert(res.msg);
})">Get authorization</button>
<?php endif; ?>

<img src="/cdn/logo" alt="Only authorized users are allowed to see this image." width="260">
<h1>Fast Raven is working hard to launch this site...</h1>