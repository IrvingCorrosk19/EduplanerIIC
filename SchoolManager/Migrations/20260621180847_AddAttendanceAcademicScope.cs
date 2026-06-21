using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddAttendanceAcademicScope : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "academic_year_id",
                table: "attendance",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "trimester_id",
                table: "attendance",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Attendance_AcademicYearId",
                table: "attendance",
                column: "academic_year_id");

            migrationBuilder.CreateIndex(
                name: "IX_Attendance_Date_Trimester",
                table: "attendance",
                columns: new[] { "date", "trimester_id" });

            migrationBuilder.CreateIndex(
                name: "IX_Attendance_Student_Trimester",
                table: "attendance",
                columns: new[] { "student_id", "trimester_id" });

            migrationBuilder.CreateIndex(
                name: "IX_Attendance_TrimesterId",
                table: "attendance",
                column: "trimester_id");

            migrationBuilder.AddForeignKey(
                name: "attendance_academic_year_id_fkey",
                table: "attendance",
                column: "academic_year_id",
                principalTable: "academic_years",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "attendance_trimester_id_fkey",
                table: "attendance",
                column: "trimester_id",
                principalTable: "trimester",
                principalColumn: "id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "attendance_academic_year_id_fkey",
                table: "attendance");

            migrationBuilder.DropForeignKey(
                name: "attendance_trimester_id_fkey",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_Attendance_AcademicYearId",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_Attendance_Date_Trimester",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_Attendance_Student_Trimester",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_Attendance_TrimesterId",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "academic_year_id",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "trimester_id",
                table: "attendance");
        }
    }
}
