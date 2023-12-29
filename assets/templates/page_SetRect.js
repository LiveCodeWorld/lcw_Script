var element = document.getElementById('[[pageSlug]]');
if (element) {
    element.style.position = 'absolute'; // or 'relative', 'fixed', etc., as needed

    element.style.top = '[[sTop]]px';
    element.style.left = '[[sLeft]]px';
    element.style.width = '[[sWidth]]px';
    element.style.height = '[[sHeight]]px';
    liveCode.javascript_Result('');
} else {
    liveCode.javascript_Result('Error, element with id "astral-ship" not found.');
}
