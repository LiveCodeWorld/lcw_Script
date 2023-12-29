function scaleAndMove(pageId, scale, targetX, targetY, pSeconds) {
    var pageElement = document.getElementById(pageId);

    if (pageElement) {
        // Store the original position and dimensions if not already stored
        if (!pageElement.dataset.originalRect) {
            var initialRect = pageElement.getBoundingClientRect();
            pageElement.dataset.originalRect = JSON.stringify({
                left: initialRect.left + window.scrollX,
                top: initialRect.top + window.scrollY,
                width: initialRect.width,
                height: initialRect.height
            });
        }

        var originalRect = JSON.parse(pageElement.dataset.originalRect);

        // Set the transform origin to the top left corner
        pageElement.style.transformOrigin = 'top left';

        // Calculate the translation needed
        var translateX = targetX - originalRect.left;
        var translateY = targetY - originalRect.top;

        // Set transition for smooth scaling and translating
        pageElement.style.transition = `transform ${pSeconds}s [[pEaseHow]]`;

        // Apply scale and translation
        pageElement.style.transform = `translate(${translateX}px, ${translateY}px) scale(${scale})`;
    } else {
        liveCode.javascript_Result('Error, page element with id "' + pageId + '" not found.');
    }
}

scaleAndMove('[[pSlug]]', [[pScale]], [[pX]], [[pY]], [[pSeconds]]); 