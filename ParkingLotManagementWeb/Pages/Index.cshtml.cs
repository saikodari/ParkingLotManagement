using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using ParkingLotManagement.Data.Models;
using ParkingLotManagementLogic.Contracts;
using ParkingLotManagementWeb.ViewModels;

namespace ParkingLotManagementWeb.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;
        private readonly ICustomer _customer;
        private readonly IConfiguration _configuration;
        public IndexModel(ILogger<IndexModel> logger, ICustomer customer, IConfiguration configuration)
        {
            _logger = logger;
            _customer = customer;
            _configuration = configuration;
        }
        public ParkingLotSettings? ParkingLot { get; set; }
        public void OnGet()
        {

        }

        public async Task<PartialViewResult> OnGetParkingLotStatusPartial()
        {
            ParkingLot = new ParkingLotSettings();
            var statistcs = await _customer.GetParkingLotStatistics();
            ParkingLot.SpotsTaken = statistcs.SpotsTaken;
            ParkingLot.AvailableSpots = statistcs.AvailableSpots;
            ParkingLot.HourlyFee= _configuration.GetSection("ParkingLotSettings").GetValue<decimal>("HourlyFee");
            ParkingLot.TotalSpots = _configuration.GetSection("ParkingLotSettings").GetValue<int>("TotalSpots");
            var parkedCar = await _customer.GetParkedCars();
            ParkingLot.ParkedCarViewModel = BindParkedCarModel(parkedCar);

            return new PartialViewResult
            {
                ViewName = "_ParkingLotStatus",
                ViewData = new ViewDataDictionary<ParkingLotSettings>(ViewData, ParkingLot)
            };
        }
        public async Task<PartialViewResult> OnGetParkingLotStatsPartial()
        {
            var res = await _customer.GetParkingLotStats();
            var data = BindParkingLotStats(res);
            return new PartialViewResult
            {
                ViewName = "_ParkingLotStats",
                ViewData = new ViewDataDictionary<ParkingLotStatsViewModel>(ViewData, data)
            };
        }



        public async Task<JsonResult> OnPostCheckInAsync(string tagNumber)
        {
            int availableSpots = await AreSpotsAvailable();
            if (availableSpots == 0)
            {
                return new JsonResult(new { success = false, message = "No available parking spots." });
            }

            if (await IsCarAlreadyParked(tagNumber))
            {
                return new JsonResult(new { success = false, message = "Car is already parked." });
            }
            var dto = new ParkedCar
            {
                TagNumber = tagNumber
            };
            var res = _customer.InsertCheckInDataAsync(dto);

            return new JsonResult(new { success = true, message = "Record Saved." });
        }
        public async Task<JsonResult> OnPostCheckOutAsync(string tagNumber)
        {
            bool isCarRegistered = await IsCarAlreadyParked(tagNumber);
            if (!isCarRegistered)
            {
                return new JsonResult(new { success = false, message = "Car not found in the parking lot." });
            }
            var amount = await CalculateParkingFeeAsync(tagNumber);
            var dto = new ParkedCar
            {
                ExitTime = DateTime.Now,
                TagNumber = tagNumber,
                Amount = amount
            };
            await _customer.InsertCheckOutDataAsync(dto);
            return new JsonResult(new { success = true, amount });
        }


        private Task<int> AreSpotsAvailable()
        {
            var res = _customer.GetAvailableSpotsCountAsync();
            return res;
        }

        private Task<bool> IsCarAlreadyParked(string tagNumber)
        {
            return _customer.IsCarAlreadyParkedAsync(tagNumber);
        }
        private static List<ParkedCarViewModel> BindParkedCarModel(List<ParkedCar> parkedCar)
        {
            List<ParkedCarViewModel> parkedCarViewModels = new();

            foreach (var car in parkedCar)
            {
                ParkedCarViewModel carViewModel = new ParkedCarViewModel
                {
                    Id = car.Id,
                    TagNumber = car.TagNumber,
                    EntryTime = car.EntryTime,
                    ExitTime = car.ExitTime,
                    Status = car.Status,
                    SpotId = car.SpotId,
                    ElapsedHours = car.ElapsedHours

                };
                parkedCarViewModels.Add(carViewModel);
            }
            return parkedCarViewModels;
        }

        private async Task<decimal> CalculateParkingFeeAsync(string tagNumber)
        {
            try
            {
                decimal hourlyFee = _configuration.GetSection("ParkingLotSettings").GetValue<decimal>("HourlyFee");
                var car = await _customer.GetParkedCarByName(tagNumber);
                TimeSpan stayDuration = DateTime.Now - car.EntryTime;
                decimal totalHours = (decimal)stayDuration.TotalHours;
                decimal totalAmount = 0;

                if (totalHours >= 0 && totalHours <= 1)
                {
                    totalAmount = hourlyFee;
                }
                else if (totalHours > 1)
                {
                    totalAmount = hourlyFee + (Math.Ceiling(totalHours) - 1) * hourlyFee;
                }

                return decimal.Round(totalAmount, 2);
            }
            catch (Exception ex)
            {
                throw;
            }
        }


        private static ParkingLotStatsViewModel BindParkingLotStats(ParkingLotStats parkingLotStats)
        {
            ParkingLotStatsViewModel stats = new();
            stats.AvailableSpots = parkingLotStats.AvailableSpots;
            stats.AvgCarsPerDay = parkingLotStats.AvgCarsPerDay;
            stats.AvgRevenuePerDay = parkingLotStats.AvgRevenuePerDay;
            stats.TodayRevenue = parkingLotStats.TodayRevenue;
            return stats;
        }
    }
}