using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class FixAttendanceCreatedAtOnly : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Corregir solo la columna created_at de attendance
            migrationBuilder.Sql(@"
                ALTER TABLE attendance 
                ALTER COLUMN created_at TYPE timestamp with time zone 
                USING created_at AT TIME ZONE 'UTC';
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Revertir el cambio
            migrationBuilder.Sql(@"
                ALTER TABLE attendance 
                ALTER COLUMN created_at TYPE timestamp without time zone;
            ");
        }
    }
}
