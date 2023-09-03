using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ParkingLotManagement.Data.Models
{
    public class ParkedCar
    {

        public int Id { get; set; }
        public string TagNumber { get; set; }
        public DateTime EntryTime { get; set; }
        public DateTime? ExitTime { get; set; } 
        public int Status { get; set; }
        public int SpotId { get; set; }
        public int ElapsedHours { get; set; }
        public int ElapsedMinutes { get; set; }
        public decimal Amount { get; set; }

    }
}
