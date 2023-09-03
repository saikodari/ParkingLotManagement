using ParkingLotManagement.Data.Contracts;
using ParkingLotManagement.Data.Models;
using ParkingLotManagementLogic.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ParkingLotManagementLogic
{
    public class Customer : ICustomer
    {
        private readonly IDataRepository _dataRepository;

        public Customer(IDataRepository dataRepository)
        {
            _dataRepository = dataRepository;
        }

        public async Task<int> GetAvailableSpotsCountAsync()
        {
           return await _dataRepository.GetAvailableSpotsCountAsync();
        }

        public async Task<int> InsertCheckInDataAsync(ParkedCar parkedCar)
        {
            return await _dataRepository.InsertCheckInDataAsync(parkedCar);
        }

        public async Task<int> InsertCheckOutDataAsync(ParkedCar parkedCar)
        {
            return await _dataRepository.InsertCheckOutDataAsync(parkedCar);

        }
        public async Task<bool> IsCarAlreadyParkedAsync(string tagNumber)
        {
            return await _dataRepository.IsCarAlreadyParkedAsync(tagNumber);
        }
        public async Task<List<ParkedCar>> GetParkedCars()
        {
            return await _dataRepository.GetParkedCars();
        }

        public async Task<ParkedCar> GetParkedCarByName(string tagNumber)
        {
            return await _dataRepository.GetParkedCarByName(tagNumber);
        }

        public async Task<ParkingLotStats> GetParkingLotStats()
        {
           return await _dataRepository.GetParkingLotStats();
        }
        public async Task<ParkingLotStatistics> GetParkingLotStatistics()
        {
            return await _dataRepository.GetParkingLotStatistics();
        }
    }
}
