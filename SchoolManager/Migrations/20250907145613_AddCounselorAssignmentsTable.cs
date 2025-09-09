using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddCounselorAssignmentsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_EmailConfigurations_schools_SchoolId",
                table: "EmailConfigurations");

            migrationBuilder.DropPrimaryKey(
                name: "PK_EmailConfigurations",
                table: "EmailConfigurations");

            migrationBuilder.RenameTable(
                name: "EmailConfigurations",
                newName: "email_configurations");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "email_configurations",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UpdatedAt",
                table: "email_configurations",
                newName: "updated_at");

            migrationBuilder.RenameColumn(
                name: "SmtpUsername",
                table: "email_configurations",
                newName: "smtp_username");

            migrationBuilder.RenameColumn(
                name: "SmtpUseTls",
                table: "email_configurations",
                newName: "smtp_use_tls");

            migrationBuilder.RenameColumn(
                name: "SmtpUseSsl",
                table: "email_configurations",
                newName: "smtp_use_ssl");

            migrationBuilder.RenameColumn(
                name: "SmtpServer",
                table: "email_configurations",
                newName: "smtp_server");

            migrationBuilder.RenameColumn(
                name: "SmtpPort",
                table: "email_configurations",
                newName: "smtp_port");

            migrationBuilder.RenameColumn(
                name: "SmtpPassword",
                table: "email_configurations",
                newName: "smtp_password");

            migrationBuilder.RenameColumn(
                name: "SchoolId",
                table: "email_configurations",
                newName: "school_id");

            migrationBuilder.RenameColumn(
                name: "IsActive",
                table: "email_configurations",
                newName: "is_active");

            migrationBuilder.RenameColumn(
                name: "FromName",
                table: "email_configurations",
                newName: "from_name");

            migrationBuilder.RenameColumn(
                name: "FromEmail",
                table: "email_configurations",
                newName: "from_email");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "email_configurations",
                newName: "created_at");

            migrationBuilder.RenameIndex(
                name: "IX_EmailConfigurations_SchoolId",
                table: "email_configurations",
                newName: "idx_email_configurations_school_id");

            migrationBuilder.AlterColumn<Guid>(
                name: "id",
                table: "email_configurations",
                type: "uuid",
                nullable: false,
                defaultValueSql: "gen_random_uuid()",
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AlterColumn<bool>(
                name: "smtp_use_tls",
                table: "email_configurations",
                type: "boolean",
                nullable: false,
                defaultValue: true,
                oldClrType: typeof(bool),
                oldType: "boolean");

            migrationBuilder.AlterColumn<bool>(
                name: "smtp_use_ssl",
                table: "email_configurations",
                type: "boolean",
                nullable: false,
                defaultValue: true,
                oldClrType: typeof(bool),
                oldType: "boolean");

            migrationBuilder.AlterColumn<int>(
                name: "smtp_port",
                table: "email_configurations",
                type: "integer",
                nullable: false,
                defaultValue: 587,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<bool>(
                name: "is_active",
                table: "email_configurations",
                type: "boolean",
                nullable: false,
                defaultValue: true,
                oldClrType: typeof(bool),
                oldType: "boolean");

            migrationBuilder.AddPrimaryKey(
                name: "email_configurations_pkey",
                table: "email_configurations",
                column: "id");

            migrationBuilder.CreateTable(
                name: "counselor_assignments",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "uuid_generate_v4()"),
                    school_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    grade_id = table.Column<Guid>(type: "uuid", nullable: true),
                    group_id = table.Column<Guid>(type: "uuid", nullable: true),
                    is_counselor = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP")
                },
                constraints: table =>
                {
                    table.PrimaryKey("counselor_assignments_pkey", x => x.id);
                    table.ForeignKey(
                        name: "counselor_assignments_grade_id_fkey",
                        column: x => x.grade_id,
                        principalTable: "grade_levels",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "counselor_assignments_group_id_fkey",
                        column: x => x.group_id,
                        principalTable: "groups",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "counselor_assignments_school_id_fkey",
                        column: x => x.school_id,
                        principalTable: "schools",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "counselor_assignments_user_id_fkey",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "counselor_assignments_school_grade_key",
                table: "counselor_assignments",
                columns: new[] { "school_id", "grade_id" },
                unique: true,
                filter: "grade_id IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "counselor_assignments_school_group_key",
                table: "counselor_assignments",
                columns: new[] { "school_id", "group_id" },
                unique: true,
                filter: "group_id IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "counselor_assignments_school_user_key",
                table: "counselor_assignments",
                columns: new[] { "school_id", "user_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "idx_counselor_assignments_grade",
                table: "counselor_assignments",
                column: "grade_id");

            migrationBuilder.CreateIndex(
                name: "idx_counselor_assignments_group",
                table: "counselor_assignments",
                column: "group_id");

            migrationBuilder.CreateIndex(
                name: "idx_counselor_assignments_school",
                table: "counselor_assignments",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "idx_counselor_assignments_user",
                table: "counselor_assignments",
                column: "user_id");

            migrationBuilder.AddForeignKey(
                name: "email_configurations_school_id_fkey",
                table: "email_configurations",
                column: "school_id",
                principalTable: "schools",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "email_configurations_school_id_fkey",
                table: "email_configurations");

            migrationBuilder.DropTable(
                name: "counselor_assignments");

            migrationBuilder.DropPrimaryKey(
                name: "email_configurations_pkey",
                table: "email_configurations");

            migrationBuilder.RenameTable(
                name: "email_configurations",
                newName: "EmailConfigurations");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "EmailConfigurations",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "updated_at",
                table: "EmailConfigurations",
                newName: "UpdatedAt");

            migrationBuilder.RenameColumn(
                name: "smtp_username",
                table: "EmailConfigurations",
                newName: "SmtpUsername");

            migrationBuilder.RenameColumn(
                name: "smtp_use_tls",
                table: "EmailConfigurations",
                newName: "SmtpUseTls");

            migrationBuilder.RenameColumn(
                name: "smtp_use_ssl",
                table: "EmailConfigurations",
                newName: "SmtpUseSsl");

            migrationBuilder.RenameColumn(
                name: "smtp_server",
                table: "EmailConfigurations",
                newName: "SmtpServer");

            migrationBuilder.RenameColumn(
                name: "smtp_port",
                table: "EmailConfigurations",
                newName: "SmtpPort");

            migrationBuilder.RenameColumn(
                name: "smtp_password",
                table: "EmailConfigurations",
                newName: "SmtpPassword");

            migrationBuilder.RenameColumn(
                name: "school_id",
                table: "EmailConfigurations",
                newName: "SchoolId");

            migrationBuilder.RenameColumn(
                name: "is_active",
                table: "EmailConfigurations",
                newName: "IsActive");

            migrationBuilder.RenameColumn(
                name: "from_name",
                table: "EmailConfigurations",
                newName: "FromName");

            migrationBuilder.RenameColumn(
                name: "from_email",
                table: "EmailConfigurations",
                newName: "FromEmail");

            migrationBuilder.RenameColumn(
                name: "created_at",
                table: "EmailConfigurations",
                newName: "CreatedAt");

            migrationBuilder.RenameIndex(
                name: "idx_email_configurations_school_id",
                table: "EmailConfigurations",
                newName: "IX_EmailConfigurations_SchoolId");

            migrationBuilder.AlterColumn<Guid>(
                name: "Id",
                table: "EmailConfigurations",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldDefaultValueSql: "gen_random_uuid()");

            migrationBuilder.AlterColumn<bool>(
                name: "SmtpUseTls",
                table: "EmailConfigurations",
                type: "boolean",
                nullable: false,
                oldClrType: typeof(bool),
                oldType: "boolean",
                oldDefaultValue: true);

            migrationBuilder.AlterColumn<bool>(
                name: "SmtpUseSsl",
                table: "EmailConfigurations",
                type: "boolean",
                nullable: false,
                oldClrType: typeof(bool),
                oldType: "boolean",
                oldDefaultValue: true);

            migrationBuilder.AlterColumn<int>(
                name: "SmtpPort",
                table: "EmailConfigurations",
                type: "integer",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer",
                oldDefaultValue: 587);

            migrationBuilder.AlterColumn<bool>(
                name: "IsActive",
                table: "EmailConfigurations",
                type: "boolean",
                nullable: false,
                oldClrType: typeof(bool),
                oldType: "boolean",
                oldDefaultValue: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_EmailConfigurations",
                table: "EmailConfigurations",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_EmailConfigurations_schools_SchoolId",
                table: "EmailConfigurations",
                column: "SchoolId",
                principalTable: "schools",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
