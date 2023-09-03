using ParkingLotManagement.Data.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ParkingLotManagement.Data.Contracts
{
    public interface IDataRepository
    {
        Task<int> InsertCheckInDataAsync(ParkedCar parkedCar);
        Task<int> InsertCheckOutDataAsync(ParkedCar parkedCar);        
        Task<bool> IsCarAlreadyParkedAsync(string tagNumber);
        Task<int> GetAvailableSpotsCountAsync();
        Task<List<ParkedCar>> GetParkedCars();
        Task<ParkedCar> GetParkedCarByName(string tagNumber);
        Task<ParkingLotStats> GetParkingLotStats();
        Task<ParkingLotStatistics> GetParkingLotStatistics();

    }
}

