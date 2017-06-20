const activePage = function (link) {
	let activeLink = $('#nav-wrap nav > a.active');
	let activeSecondary = null;
	let currentPage = activeLink.text();

	if (link) {
		activeLink = link;
		if (activeLink.parent().hasClass('secondary')) {
			currentPage = activeLink.parent().prev('.has-secondary').text();
		} else {
			currentPage = activeLink.text();
		}

			// Change active classes
		if (!activeLink.hasClass('active')) {
			// Remove all active classes
			$('nav:not(#secondary) a').removeClass('active');
			// Add active class to link that was clicked
			activeLink.addClass('active');
			// Add active class to link's parent if nested
			if (activeLink.parent().hasClass('secondary')) {
				activeLink.parent().prev('.has-secondary').addClass('active');
			}
			// Add active class to first child if there are any
			if (activeLink.hasClass('has-secondary')) {
				activeLink.next('.secondary').find('a:first-child').addClass('active');
			}
		}
	}
		// Populate current primary page text in mobile nav
	$('#current-page').text(currentPage);

		// Populate desktop #secondary nav
	if (activeLink.hasClass('has-secondary')) {
		activeSecondary = activeLink.next('.secondary').html();
		$('#secondary').html(activeSecondary).show();
	}		else if (activeLink.parent().hasClass('secondary')) {
		activeSecondary = activeLink.parent().html();
		$('#secondary').html(activeSecondary).show();
	}		else {
		activeSecondary = null;
		$('#secondary').html(activeSecondary).hide();
	}
};

$(document).ready(() => {
	activePage();
	const sidebar = $('section#main').hasClass('sidebar');

		// Change active nav item
	$('nav#utility, nav#primary').on('click', 'a', function () {
		activePage($(this));
	});
	$('nav#secondary').on('click', 'a', function () {
		if (!$(this).hasClass('active')) {
			// Set active
			$(this).addClass('active').siblings('a').removeClass('active');
			// Set mobile version active
			$('nav#utility, nav#primary').find('.secondary a').removeClass('active');
			$('nav#utility, nav#primary').find('.secondary a:contains("' + $(this).text() + '")').addClass('active');
		}
	});

		// Show/hide primary children (secondary nav) for mobile
	$('nav a.has-secondary i').click(function (e) {
		$(this).toggleClass('icons8-visible').toggleClass('icons8-hide');
		$(this).parent('a').next('.secondary').slideToggle(200);
			// Stop parent link from going anywhere
		e.preventDefault();
		e.stopPropagation();
	});

		// Responsive actions
	$('i.icons8-menu').click(function () {
		const menuIcon = $(this);
		if (menuIcon.hasClass('icons8-menu')) {
			// Icon
			menuIcon.fadeOut(200);
			setTimeout(() => {
				menuIcon.removeClass('icons8-menu').addClass('icons8-delete').fadeIn(200);
			}, 200);

			// Current page
			$('#mobile-menu #current-page').css('opacity', 0);

			// Navs
			$('#nav-wrap').slideDown(200);
			setTimeout(() => {
				$('#nav-wrap nav').css('opacity', 1);
			}, 200);
		} else if (menuIcon.hasClass('icons8-delete')) {
			// Icon
			menuIcon.fadeOut(200);
			setTimeout(() => {
				menuIcon.removeClass('icons8-delete').addClass('icons8-menu').fadeIn(200);
			}, 200);

			// Current page
			setTimeout(() => {
				$('#mobile-menu #current-page').css('opacity', 1);
			}, 200);

			// Navs
			$('#nav-wrap nav').css('opacity', 0);
			setTimeout(() => {
				$('#nav-wrap').slideUp(200);
			}, 200);
		}
	});

	// Window resize
	let windowWidth = $(window).width();
	$(window).resize(function () {
		// Helps determine width increase or decrease
		const oldWidth = windowWidth;
		let newWidth;
		if ($(this).width() !== windowWidth) {
			windowWidth = $(this).width();
			newWidth = windowWidth;
		}
		// Go back to desktop styles
		if (windowWidth > 999) {
			// Reset menu stuff
			$('#nav-wrap').css('display', 'table-cell');
			$('#nav-wrap nav').css('opacity', 1);
			$('#mobile-menu i').removeClass('icons8-delete').addClass('icons8-menu');
			$('.secondary').hide();
			$('a.has-secondary i').removeClass('icons8-hide').addClass('icons8-visible');
			if ($('#secondary').html() !== '') {
				if (sidebar) {
					$('#secondary').css('display', 'table-cell');
				} else {
					$('#secondary').show();
				}
			}
		}	else if (oldWidth >= 1000 && newWidth <= 999) {
			$('#nav-wrap').css('display', 'none');
			$('#nav-wrap nav').css('opacity', 0);
			$('#mobile-menu #current-page').css('opacity', 1);
		}
	});
});
