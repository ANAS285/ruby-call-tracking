$(document).ready(() => {
	$('a').each(function () {
		const anchor = this;
		const anchorHtml = $(anchor).html();
		const anchorText = $(anchor).text();

		if (anchorHtml === anchorText) {
			// Text only, do nothing
		} else if (anchorHtml.length > anchorText.length) {
			// Text is shorter than HTML
			if (anchorText.length === 0) {
				// HTML only
				$(anchor).has('i').addClass('anchor-i');
				$(anchor).has('img').addClass('anchor-img');
			} else {
				// Code snippets
				$(anchor).has('code').addClass('anchor-code');
				// Text and icon, check for external icon
				if ($(anchor).find('i').hasClass('icons8-open-in-window')) {
					// External link, show icon on hover
					$(anchor).has('i').addClass('anchor-external');
				} else {
					// Do nothing, show icon all the time
				}
			}
		}
	});
});
