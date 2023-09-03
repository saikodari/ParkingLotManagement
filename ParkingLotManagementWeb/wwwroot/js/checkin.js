$(document).ready(function () {
    //$('#parkingLotStatus').load('?handler=ParkingLotStatusPartial');
    reloadParkingLotStatus();
    checkIn = (tagNumber) => {
        debugger;
        try {
            $.ajax({
                type: "POST",
                cache: false,
                url: '?handler=CheckIn&tagNumber=' + tagNumber,
                beforeSend: function (xhr) {
                    xhr.setRequestHeader("XSRF-TOKEN",
                        $('input:hidden[name="__RequestVerificationToken"]').val());
                },
                data: tagNumber,
                contentType: "json; charset=utf-8",
                success: function (res) {
                    debugger;
                    if (res.success) {
                        //$('#parkingLotStatus').load('?handler=ParkingLotStatusPartial');
                        reloadParkingLotStatus();
                        successAlert(res.message);                        
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