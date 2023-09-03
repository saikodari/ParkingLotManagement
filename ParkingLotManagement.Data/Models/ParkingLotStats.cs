using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ParkingLotManagement.Data.Models
{
    public class ParkingLotStats
    {
        public int AvailableSpots { get; set; }
        public decimal TodayRevenue { get; set; }
        public int AvgCarsPerDay { get; set; }
        public decimal AvgRevenuePerDay { get; set; }
    }
}
    