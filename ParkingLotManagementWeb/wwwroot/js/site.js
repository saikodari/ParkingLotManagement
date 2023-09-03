var successAlert = function (message = successMessage) {

    toastr.success(message, 'Success', { "closeButton": true });
}

var errorAlert = function (message = errorMessage) {

    toastr.error(message, 'Error', { "closeButton": true });
};
var paymentAlert = function (message = infoMessage, amount = amount) {
    toastr.info(message + ' Amount: $' + amount.toFixed(2), 'Payment Information', { "closeButton": true });
};
function reloadParkingLotStatus() {
    $('#parkingLotStatus').load('?handler=ParkingLotStatusPartial');
}


function isAlphaNumeric(input) {
    return /^[A-Za-z0-9]{4,8}$/.test(input);
}