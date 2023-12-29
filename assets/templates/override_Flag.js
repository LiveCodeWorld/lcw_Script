function flagClick(event) {
var h1El = event.target.closest('.header > h1');
if (h1El) {
 event.preventDefault();
 event.stopPropagation();
 var anchor = h1El.querySelector('a');
 if (anchor) {
  var href = anchor.getAttribute('href');
  var targetAttr = anchor.getAttribute('target');
  var yString = 'target:' + targetAttr + ',href:' + href;
  liveCode.[[flagHandler]](yString);
}}}

document.body.addEventListener('click', flagClick, true);