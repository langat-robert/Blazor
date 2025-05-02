namespace Backend.Data
{
    public class AddressView
    {
        public int CountyID { get; set; }
        public string? CountyName { get; set; }
        public int SubCountyID { get; set; }
        public string? SubCountyName { get; set; }
        public int LocationID { get; set; }
        public string? LocationName { get; set; }
        public int SubLocationID { get; set; }
        public string? SubLocationName { get; set; }
        public int VillageID { get; set; }
        public string? VillageName { get; set; }
    }
}