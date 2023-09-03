using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using ParkingLotManagement.Data.Constants;
using ParkingLotManagement.Data.Contracts;
using ParkingLotManagement.Data.Models;
using System.Data;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace ParkingLotManagement.Data
{
    public class DataRepository : IDataRepository
    {

        private readonly string _connectionString;

        public DataRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<int> GetAvailableSpotsCountAsync()
        {
            try
            {

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                string storedProcedureName = "GetUnoccupiedParkingSpotCount";
                //string sql = "SELECT COUNT(*) FROM ParkingSpots WHERE IsOccupied = 0";
                var res = await connection.QueryFirstOrDefaultAsync<int>(storedProcedureName, commandType: CommandType.StoredProcedure);
                return res;
            }
            catch (Exception ex)
            {

                throw;
            }
        }

        //public async Task<int> InsertCheckInDataAsync(ParkedCar parkedCar)
        //{
        //    try
        //    {
        //        using var connection = new SqlConnection(_connectionString);
        //        await connection.OpenAsync();
        //        int spotNumber = await AssignParkingSpot();
        //        string storedProcedureName = DataConstants.SN_EXECUTE__CHECK_IN_INSERTDATA;
        //        var parameters = new
        //        {
        //            TagNumber = parkedCar.TagNumber,
        //            EntryTime = DateTime.Now,
        //            Status = 1,
        //            SpotId = spotNumber
        //        };

        //        var res= await connection.ExecuteAsync(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);
        //        return res;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw;
        //    }
        //    return 0;
        //}
        public async Task<int> InsertCheckInDataAsync(ParkedCar parkedCar)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                string storedProcedureName = "CheckInCar";
                var parameters = new
                {
                    TagNumber = parkedCar.TagNumber,
                    EntryTime = DateTime.Now,
                    Status = 1
                };

                // Execute the stored procedure and retrieve the assigned spot ID
                var result = await connection.QueryFirstOrDefaultAsync<int>(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);

                if (result == 0)
                {
                    // Handle the case where no available parking spots were found
                    throw new Exception("No available parking spots.");
                }

                return result;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        private async Task<int> AssignParkingSpot()
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                //var sql = "SELECT TOP 1 SpotId FROM ParkingSpot WHERE IsOccupied = 0 ORDER BY SpotNumber ASC";
                string storedProcedureName = "GetNextAvailableParkingSpot";

                var nextAvailableSpot = await connection.QueryFirstOrDefaultAsync<int?>(storedProcedureName, commandType: CommandType.StoredProcedure);

                if (nextAvailableSpot.HasValue)
                {
                    MarkSpotOccupied(nextAvailableSpot.Value);
                    return nextAvailableSpot.Value;
                }
                else
                {
                    throw new Exception("No available parking spots.");
                }
            }
            catch (Exception ex)
            {

                throw;
            }
        }
        private async void MarkSpotOccupied(int spotNumber)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
               await connection.OpenAsync();
                string storedProcedureName = "UpdateParkingSpotOccupancy";
                var parameters = new
                {
                    SpotId = spotNumber,
                    IsOccupied = 1
                };
                await connection.ExecuteAsync(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);
            }
            catch (Exception ex)
            {

                throw;
            }
        }
        public async Task<int> InsertCheckOutDataAsync(ParkedCar parkedCar)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                string storedProcedureName = "SP_CheckOutCar";
                var parameters = new
                {
                    TagNumber = parkedCar.TagNumber,
                    ExitTime = DateTime.Now,
                    Amount = parkedCar.Amount
                };

                var result = await connection.ExecuteAsync(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);

                return result;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        //public async Task<int> InsertCheckOutDataAsync(ParkedCar parkedCar)
        //{
        //    try
        //    {
        //        using var connection = new SqlConnection(_connectionString);
        //        await connection.OpenAsync();

        //        string storedProcedureName = DataConstants.SN_EXECUTE__CHECK_OUT_INSERTDATA;
        //        var parameters = new
        //        {
        //            TagNumber = parkedCar.TagNumber,
        //            ExitTime = DateTime.Now,
        //            Status = 0,
        //        };

        //        var res = await connection.ExecuteAsync(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);
        //        return res;
        //    }
        //    catch (Exception ex)
        //    {

        //        throw;
        //    }
        //}


        public async Task<bool> IsCarAlreadyParkedAsync(string tagNumber)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                string storedProcedureName = "CountParkedCarsByTagNumber";
                var parameters = new
                {
                    TagNumber = tagNumber,
                };
                var count = await connection.QueryFirstOrDefaultAsync<int?>(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);

                return count > 0;
            }
            catch (Exception ex)
            {

                throw;
            }
        }

        public async Task<List<ParkedCar>> GetParkedCars()
        {

            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                string storedProcedureName = "GetParkedCars";
                var parkedCars = await connection.QueryAsync<ParkedCar>(storedProcedureName, commandType: CommandType.StoredProcedure);
                return parkedCars.ToList();
            }
            catch (Exception ex)
            {

                throw;
            }
        }
        public async Task<ParkedCar> GetParkedCarByName(string tagNumber)
        {
            try
            {

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                string storedProcedureName = "GetParkedCar";                
                     var parameters = new
                     {
                         TagNumber = tagNumber,
                     };
                var res = await connection.QueryFirstOrDefaultAsync<ParkedCar>(storedProcedureName, parameters, commandType: CommandType.StoredProcedure);
                return res;
            }
            catch (Exception ex)
            {

                throw;
            }
        }


        public async Task<ParkingLotStats> GetParkingLotStats()
        {
            try
            {

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                string storedProcedureName = "SP_GetParkingLotStatistics";                
                var res = await connection.QueryFirstOrDefaultAsync<ParkingLotStats>(storedProcedureName, commandType: CommandType.StoredProcedure);
                return res;
            }
            catch (Exception ex)
            {

                throw;
            }
        }
        public async Task<ParkingLotStatistics> GetParkingLotStatistics()
        {
            try
            {

                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();
                string storedProcedureName = "SP_GetParkingLotSpotsStatistics";
                var res = await connection.QueryFirstOrDefaultAsync<ParkingLotStatistics>(storedProcedureName, commandType: CommandType.StoredProcedure);
                return res;
            }
            catch (Exception ex)
            {

                throw;
            }
        }
    }
}
