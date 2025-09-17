using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class FixCircularRelationDeleteBehavior : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_schools_users_admin_id",
                table: "schools");

            migrationBuilder.DropForeignKey(
                name: "users_school_id_fkey",
                table: "users");

            migrationBuilder.AddForeignKey(
                name: "FK_schools_users_admin_id",
                table: "schools",
                column: "admin_id",
                principalTable: "users",
                principalColumn: "id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "users_school_id_fkey",
                table: "users",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_schools_users_admin_id",
                table: "schools");

            migrationBuilder.DropForeignKey(
                name: "users_school_id_fkey",
                table: "users");

            migrationBuilder.AddForeignKey(
                name: "FK_schools_users_admin_id",
                table: "schools",
                column: "admin_id",
                principalTable: "users",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "users_school_id_fkey",
                table: "users",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
