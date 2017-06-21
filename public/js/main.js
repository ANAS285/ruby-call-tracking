(function () {
	const websocketUrl = 'ws' + ((window.location.protocol === 'https:') ? 's' : '') + '://' + window.location.host + '/ws';

	const state = {
		phoneNumbers: null,
		areCode: null,
		forwardTo: null,
		canAddNumber: true,
		error: null,
		selectedNumber: null,
		calls: null,
		addNumber,
		deleteNumber,
		selectNumber
	};

	const ws = new RobustWebSocket(websocketUrl);
	ws.onopen = function () {
		if (state.phoneNumbers === null) {
			sendCommand('load-phone-numbers');
		}
	};
	ws.onmessage = function (ev) {
		const data = JSON.parse(ev.data);
		if (data.error) {
			if (data.command === 'create-phone-number') {
				state.canAddNumber = true;
			}
			state.error = data.error;
			return;
		}
		if (data.notificationType === 'call') {
			const call = data.data;
			if (!state.selectedNumber || state.selectedNumber.id !== call.phoneNumberId) {
				return;
			}
			call.isNew = false;
			state.calls = state.calls || [];
			for (let i = 0; i < state.calls.length; i++) {
				if (state.calls[i].id === call.id) {
					Object.assign(state.calls[i], call);
					return;
				}
			}
			call.isNew = true;
			state.calls.unshift(call);
			return;
		}
		switch (data.command) {
			case 'load-phone-numbers': {
				state.phoneNumbers = data.result;
				state.phoneNumbers.forEach(p => {
					p.isNew = false;
				});
				break;
			}
			case 'load-calls': {
				state.calls = data.result;
				break;
			}
			case 'create-phone-number': {
				state.phoneNumbers = state.phoneNumbers || [];
				data.result.isNew = true;
				state.phoneNumbers.unshift(data.result);
				state.canAddNumber = true;
				state.areCode = '';
				state.forwardTo = '';
				break;
			}
			case 'delete-phone-number': {
				const numberId = data.result;
				state.phoneNumbers = state.phoneNumbers || [];
				for (let i = 0; i < state.phoneNumbers.length; i++) {
					if (state.phoneNumbers[i].id === numberId) {
						state.phoneNumbers[i].deleted = true;
						break;
					}
				}
				break;
			}
			default: {
				console.log('Unknown command ', data.command);
				break;
			}
		}
	};

	function sendCommand(command, payload) {
		ws.send(JSON.stringify({command, payload}));
	}

	function addNumber() {
		let forwardTo = state.forwardTo;
    if (forwardTo.startsWith('+')){
      forwardTo = forwardTo.substr(1);
    }
    if (forwardTo.length === 9) {
      forwardTo = `1${forwardTo}`;
    }
		state.canAddNumber = false;
		sendCommand('create-phone-number', {areaCode: state.areCode, forwardTo: `+${forwardTo}`});
	}

	function deleteNumber(number) {
		/* eslint no-alert: 0 */
		if (window.confirm('Are you sure you want to delete?')) {
			sendCommand('delete-phone-number', {id: number.id});
		}
	}

	function selectNumber(number) {
		state.selectedNumber = number;
		if (number) {
			state.calls = null;
			sendCommand('load-calls', {id: number.id});
		}
	}

	/* eslint no-new: 0 */
	new Vue({
		el: '.main-container',
		data: state
	});
})();
