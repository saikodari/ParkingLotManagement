namespace ParkingLotManagementWeb.ViewModels
{
    public class ParkingLotSettings
    {
        public int TotalSpots { get; set; }
        public decimal HourlyFee { get; set; }
        public List<ParkedCarViewModel> ParkedCarViewModel { get; set; }
        public int SpotsTaken { get; set; }
        public int AvailableSpots { get; set; }

    }
}
