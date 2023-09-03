
$(document).ready(function () {
    var alertBox = $('#alert-box');
    var alertMessage = $('#alert-message');
    var closeButton = $('#close-alert');
    function showAlert(message, amount) {
        alertMessage.text(message + ' $' + amount.toFixed(2));
        alertBox.css('display', 'block');
    }
    function closeAlert() {
        alertBox.css('display', 'none');
    }
    closeButton.click(closeAlert);


    //$('#parkingLotStatus').load('?handler=ParkingLotStatusPartial');
    checkOut = (tagNumber) => {
        debugger;
        try {
            $.ajax({
                type: "POST",
                cache: false,
                url: '?handler=CheckOut&tagNumber=' + tagNumber,
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("XSRF-TOKEN",
                        $('input:hidden[name="__RequestVerificationToken"]').val());
                },
                data: tagNumber,
                contentType: "json; charset=utf-8",
                success: function (res) {
                    debugger;
                    if (res.success) {
                        showAlert("Total Amount:", res.amount);
                        reloadParkingLotStatus();
                    }
                    else {
                        errorAlert(res.message);
                    }
                },
                error: function (err) {
                    errorAlert(err);
                }
            });
            return false;
        } catch (ex) {
            console.log(ex);
        }
        return false;
    }
    
});