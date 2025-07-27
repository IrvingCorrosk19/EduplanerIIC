using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class ApplyAttendanceCreatedAtTimezoneFix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Cambiar el tipo de columna created_at de timestamp without time zone a timestamp with time zone
            migrationBuilder.Sql(@"
                ALTER TABLE attendance 
                ALTER COLUMN created_at TYPE timestamp with time zone 
                USING created_at AT TIME ZONE 'UTC';
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Revertir el cambio de tipo de columna
            migrationBuilder.Sql(@"
                ALTER TABLE attendance 
                ALTER COLUMN created_at TYPE timestamp without time zone;
            ");
        }
    }
}
