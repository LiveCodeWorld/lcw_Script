var element = document.getElementById('[[pageSlug]]');
if (element) {
    var rect = element.getBoundingClientRect();
    var rectString = rect.left + ',' + rect.top + ',' + rect.right + ',' + rect.bottom;
    liveCode.javascript_Result(rectString);
} else {
    liveCode.javascript_Result('No such page');
}