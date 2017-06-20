(function () {
	Vue.filter('phone-number', value => libphonenumber.format(value, 'US', 'National'));
	Vue.filter('time', value => moment.utc(value).local().calendar());
	Vue.filter('duration', value => moment.duration(value).humanize());
	Vue.filter('state', value => value[0].toUpperCase() + value.substr(1));
	Vue.directive('make-visible', {
		inserted: (el, b) => {
			if (b.value) {
				el.scrollIntoView();
			}
		}
	});
})();
