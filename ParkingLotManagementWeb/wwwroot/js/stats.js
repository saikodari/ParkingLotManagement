jQueryModalGet = (modalName = "#parkingLotStatsModal") => {
    try {
        $.ajax({
            type: 'GET',
            url: '?handler=ParkingLotStatsPartial',
            beforeSend: function (xhr) {
                xhr.setRequestHeader("XSRF-TOKEN",
                    $('input:hidden[name="__RequestVerificationToken"]').val());
            },
            contentType: false,
            processData: false,
            success: function (res) {
                $('#parkingLotStatus').html(res);
                $(modalName + ' .modal-title').html('ParkingLot Stats');
                $(modalName).modal('show');
                reloadParkingLotStatus();
            },
            failure: function (response) {
                errorAlert(response.responseText);
            },
            error: function (response) {
                errorAlert(response.responseText);
            }
        })
        return false;
    } catch (ex) {
        console.log(ex)
    }
}