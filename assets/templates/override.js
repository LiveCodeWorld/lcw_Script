document.body.addEventListener('click', function(event) {
 var target = event.target;
 if (target.matches('a.external')) {
  event.preventDefault();
  var url = target.getAttribute('href');
  liveCode.bevent_ExternalLink(url);
  }
});