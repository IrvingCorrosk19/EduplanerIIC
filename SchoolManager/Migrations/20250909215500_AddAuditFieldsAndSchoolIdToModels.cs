using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddAuditFieldsAndSchoolIdToModels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "subjects",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "subjects",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "subjects",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "student_activity_scores",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "school_id",
                table: "student_activity_scores",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "student_activity_scores",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "student_activity_scores",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "specialties",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "school_id",
                table: "specialties",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "specialties",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "specialties",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "groups",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "groups",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "groups",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "grade_levels",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "school_id",
                table: "grade_levels",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "grade_levels",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "grade_levels",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "discipline_reports",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "school_id",
                table: "discipline_reports",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "discipline_reports",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "attendance",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "school_id",
                table: "attendance",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "attendance",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "attendance",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "activity_types",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "school_id",
                table: "activity_types",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "activity_types",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "created_by",
                table: "activities",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "updated_at",
                table: "activities",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by",
                table: "activities",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_subjects_created_by",
                table: "subjects",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_subjects_updated_by",
                table: "subjects",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_student_activity_scores_created_by",
                table: "student_activity_scores",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_student_activity_scores_school_id",
                table: "student_activity_scores",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_student_activity_scores_updated_by",
                table: "student_activity_scores",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_specialties_created_by",
                table: "specialties",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_specialties_school_id",
                table: "specialties",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_specialties_updated_by",
                table: "specialties",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_groups_created_by",
                table: "groups",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_groups_updated_by",
                table: "groups",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_grade_levels_created_by",
                table: "grade_levels",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_grade_levels_school_id",
                table: "grade_levels",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_grade_levels_updated_by",
                table: "grade_levels",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_discipline_reports_created_by",
                table: "discipline_reports",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_discipline_reports_school_id",
                table: "discipline_reports",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_discipline_reports_updated_by",
                table: "discipline_reports",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_attendance_created_by",
                table: "attendance",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_attendance_school_id",
                table: "attendance",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_attendance_updated_by",
                table: "attendance",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_activity_types_created_by",
                table: "activity_types",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_activity_types_school_id",
                table: "activity_types",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_activity_types_updated_by",
                table: "activity_types",
                column: "updated_by");

            migrationBuilder.CreateIndex(
                name: "IX_activities_created_by",
                table: "activities",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_activities_updated_by",
                table: "activities",
                column: "updated_by");

            migrationBuilder.AddForeignKey(
                name: "FK_activities_users_created_by",
                table: "activities",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_activities_users_updated_by",
                table: "activities",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_activity_types_schools_school_id",
                table: "activity_types",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_activity_types_users_created_by",
                table: "activity_types",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_activity_types_users_updated_by",
                table: "activity_types",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_attendance_schools_school_id",
                table: "attendance",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_attendance_users_created_by",
                table: "attendance",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_attendance_users_updated_by",
                table: "attendance",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_discipline_reports_schools_school_id",
                table: "discipline_reports",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_discipline_reports_users_created_by",
                table: "discipline_reports",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_discipline_reports_users_updated_by",
                table: "discipline_reports",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_grade_levels_schools_school_id",
                table: "grade_levels",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_grade_levels_users_created_by",
                table: "grade_levels",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_grade_levels_users_updated_by",
                table: "grade_levels",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_groups_users_created_by",
                table: "groups",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_groups_users_updated_by",
                table: "groups",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_specialties_schools_school_id",
                table: "specialties",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_specialties_users_created_by",
                table: "specialties",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_specialties_users_updated_by",
                table: "specialties",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_student_activity_scores_schools_school_id",
                table: "student_activity_scores",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_student_activity_scores_users_created_by",
                table: "student_activity_scores",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_student_activity_scores_users_updated_by",
                table: "student_activity_scores",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_subjects_users_created_by",
                table: "subjects",
                column: "created_by",
                principalTable: "users",
                principalColumn: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_subjects_users_updated_by",
                table: "subjects",
                column: "updated_by",
                principalTable: "users",
                principalColumn: "id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_activities_users_created_by",
                table: "activities");

            migrationBuilder.DropForeignKey(
                name: "FK_activities_users_updated_by",
                table: "activities");

            migrationBuilder.DropForeignKey(
                name: "FK_activity_types_schools_school_id",
                table: "activity_types");

            migrationBuilder.DropForeignKey(
                name: "FK_activity_types_users_created_by",
                table: "activity_types");

            migrationBuilder.DropForeignKey(
                name: "FK_activity_types_users_updated_by",
                table: "activity_types");

            migrationBuilder.DropForeignKey(
                name: "FK_attendance_schools_school_id",
                table: "attendance");

            migrationBuilder.DropForeignKey(
                name: "FK_attendance_users_created_by",
                table: "attendance");

            migrationBuilder.DropForeignKey(
                name: "FK_attendance_users_updated_by",
                table: "attendance");

            migrationBuilder.DropForeignKey(
                name: "FK_discipline_reports_schools_school_id",
                table: "discipline_reports");

            migrationBuilder.DropForeignKey(
                name: "FK_discipline_reports_users_created_by",
                table: "discipline_reports");

            migrationBuilder.DropForeignKey(
                name: "FK_discipline_reports_users_updated_by",
                table: "discipline_reports");

            migrationBuilder.DropForeignKey(
                name: "FK_grade_levels_schools_school_id",
                table: "grade_levels");

            migrationBuilder.DropForeignKey(
                name: "FK_grade_levels_users_created_by",
                table: "grade_levels");

            migrationBuilder.DropForeignKey(
                name: "FK_grade_levels_users_updated_by",
                table: "grade_levels");

            migrationBuilder.DropForeignKey(
                name: "FK_groups_users_created_by",
                table: "groups");

            migrationBuilder.DropForeignKey(
                name: "FK_groups_users_updated_by",
                table: "groups");

            migrationBuilder.DropForeignKey(
                name: "FK_specialties_schools_school_id",
                table: "specialties");

            migrationBuilder.DropForeignKey(
                name: "FK_specialties_users_created_by",
                table: "specialties");

            migrationBuilder.DropForeignKey(
                name: "FK_specialties_users_updated_by",
                table: "specialties");

            migrationBuilder.DropForeignKey(
                name: "FK_student_activity_scores_schools_school_id",
                table: "student_activity_scores");

            migrationBuilder.DropForeignKey(
                name: "FK_student_activity_scores_users_created_by",
                table: "student_activity_scores");

            migrationBuilder.DropForeignKey(
                name: "FK_student_activity_scores_users_updated_by",
                table: "student_activity_scores");

            migrationBuilder.DropForeignKey(
                name: "FK_subjects_users_created_by",
                table: "subjects");

            migrationBuilder.DropForeignKey(
                name: "FK_subjects_users_updated_by",
                table: "subjects");

            migrationBuilder.DropIndex(
                name: "IX_subjects_created_by",
                table: "subjects");

            migrationBuilder.DropIndex(
                name: "IX_subjects_updated_by",
                table: "subjects");

            migrationBuilder.DropIndex(
                name: "IX_student_activity_scores_created_by",
                table: "student_activity_scores");

            migrationBuilder.DropIndex(
                name: "IX_student_activity_scores_school_id",
                table: "student_activity_scores");

            migrationBuilder.DropIndex(
                name: "IX_student_activity_scores_updated_by",
                table: "student_activity_scores");

            migrationBuilder.DropIndex(
                name: "IX_specialties_created_by",
                table: "specialties");

            migrationBuilder.DropIndex(
                name: "IX_specialties_school_id",
                table: "specialties");

            migrationBuilder.DropIndex(
                name: "IX_specialties_updated_by",
                table: "specialties");

            migrationBuilder.DropIndex(
                name: "IX_groups_created_by",
                table: "groups");

            migrationBuilder.DropIndex(
                name: "IX_groups_updated_by",
                table: "groups");

            migrationBuilder.DropIndex(
                name: "IX_grade_levels_created_by",
                table: "grade_levels");

            migrationBuilder.DropIndex(
                name: "IX_grade_levels_school_id",
                table: "grade_levels");

            migrationBuilder.DropIndex(
                name: "IX_grade_levels_updated_by",
                table: "grade_levels");

            migrationBuilder.DropIndex(
                name: "IX_discipline_reports_created_by",
                table: "discipline_reports");

            migrationBuilder.DropIndex(
                name: "IX_discipline_reports_school_id",
                table: "discipline_reports");

            migrationBuilder.DropIndex(
                name: "IX_discipline_reports_updated_by",
                table: "discipline_reports");

            migrationBuilder.DropIndex(
                name: "IX_attendance_created_by",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_attendance_school_id",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_attendance_updated_by",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_activity_types_created_by",
                table: "activity_types");

            migrationBuilder.DropIndex(
                name: "IX_activity_types_school_id",
                table: "activity_types");

            migrationBuilder.DropIndex(
                name: "IX_activity_types_updated_by",
                table: "activity_types");

            migrationBuilder.DropIndex(
                name: "IX_activities_created_by",
                table: "activities");

            migrationBuilder.DropIndex(
                name: "IX_activities_updated_by",
                table: "activities");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "subjects");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "subjects");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "subjects");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "student_activity_scores");

            migrationBuilder.DropColumn(
                name: "school_id",
                table: "student_activity_scores");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "student_activity_scores");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "student_activity_scores");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "specialties");

            migrationBuilder.DropColumn(
                name: "school_id",
                table: "specialties");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "specialties");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "specialties");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "groups");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "groups");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "groups");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "grade_levels");

            migrationBuilder.DropColumn(
                name: "school_id",
                table: "grade_levels");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "grade_levels");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "grade_levels");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "discipline_reports");

            migrationBuilder.DropColumn(
                name: "school_id",
                table: "discipline_reports");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "discipline_reports");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "school_id",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "activity_types");

            migrationBuilder.DropColumn(
                name: "school_id",
                table: "activity_types");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "activity_types");

            migrationBuilder.DropColumn(
                name: "created_by",
                table: "activities");

            migrationBuilder.DropColumn(
                name: "updated_at",
                table: "activities");

            migrationBuilder.DropColumn(
                name: "updated_by",
                table: "activities");
        }
    }
}
