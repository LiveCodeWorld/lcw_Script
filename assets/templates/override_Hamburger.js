$('footer span').filter(function() {
  return $(this).text().trim() === '☰';
}).off('click').on('click', function(event) {
  event.stopPropagation();
  liveCode.wikiClick_HamburgerMenu();
});

