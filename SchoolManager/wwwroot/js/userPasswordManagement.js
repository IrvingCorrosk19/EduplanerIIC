/**
 * User Password Management - list users, filter by role, select multiple users.
 * Prepares for future Mass Password Delivery feature.
 */
var userPasswordManagement = (function () {
    'use strict';

    var config = {
        listUrl: '',
        filterByRoleUrl: ''
    };

    var dataTable = null;
    var currentData = [];

    function formatDate(dateStr) {
        if (!dateStr) return '';
        var d = new Date(dateStr);
        if (isNaN(d.getTime())) return dateStr;
        return d.toLocaleDateString('es-PA', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    function getRoleDisplayName(role) {
        if (!role) return '';
        var r = (role + '').toLowerCase();
        if (r === 'superadmin') return 'SuperAdmin';
        if (r === 'admin') return 'Admin';
        if (r === 'teacher') return 'Teacher';
        if (r === 'student' || r === 'estudiante') return 'Student';
        return role;
    }

    /**
     * Load all users (for DataTables).
     */
    function loadUsers() {
        return $.ajax({
            url: config.listUrl,
            type: 'GET',
            dataType: 'json'
        }).done(function (data) {
            currentData = Array.isArray(data) ? data : [];
            renderTable(currentData);
        }).fail(function (xhr) {
            console.error('userPasswordManagement: loadUsers failed', xhr);
            currentData = [];
            renderTable([]);
        });
    }

    /**
     * Filter users by role (All, SuperAdmin, Admin, Teacher, Student).
     */
    function filterByRole(role) {
        var url = config.filterByRoleUrl;
        if (role && role !== 'All' && role !== '') {
            url += (url.indexOf('?') >= 0 ? '&' : '?') + 'role=' + encodeURIComponent(role);
        }
        return $.ajax({
            url: url,
            type: 'GET',
            dataType: 'json'
        }).done(function (data) {
            currentData = Array.isArray(data) ? data : [];
            renderTable(currentData);
        }).fail(function (xhr) {
            console.error('userPasswordManagement: filterByRole failed', xhr);
            currentData = [];
            renderTable([]);
        });
    }

    /**
     * Render the table with data and (re)initialize DataTables.
     */
    function renderTable(users) {
        var $table = $('#usersTable');
        var $tbody = $table.find('tbody');
        $tbody.empty();

        users.forEach(function (u) {
            var name = (u.firstName || '') + ' ' + (u.lastName || '').trim();
            if (!name.trim()) name = u.email || '';
            var row = '<tr data-id="' + (u.id || '') + '">' +
                '<td><input type="checkbox" class="user-select-cb" value="' + (u.id || '') + '" /></td>' +
                '<td>' + escapeHtml(name) + '</td>' +
                '<td>' + escapeHtml(u.email || '') + '</td>' +
                '<td>' + escapeHtml(getRoleDisplayName(u.role)) + '</td>' +
                '<td>' + escapeHtml(u.status || '') + '</td>' +
                '<td>' + escapeHtml(formatDate(u.createdAt)) + '</td>' +
                '</tr>';
            $tbody.append(row);
        });

        if (dataTable && $.fn.DataTable.isDataTable($table)) {
            dataTable.destroy();
            dataTable = null;
        }

        dataTable = $table.DataTable({
            pageLength: 25,
            order: [[1, 'asc']],
            columnDefs: [
                { orderable: false, targets: 0 }
            ],
            language: {
                search: 'Buscar:',
                lengthMenu: 'Mostrar _MENU_ registros',
                info: 'Mostrando _START_ a _END_ de _TOTAL_',
                infoEmpty: 'Sin registros',
                infoFiltered: '(filtrado de _MAX_)',
                paginate: {
                    first: 'Primera',
                    last: 'Última',
                    next: 'Siguiente',
                    previous: 'Anterior'
                }
            }
        });

        handleCheckboxSelection();
    }

    function escapeHtml(text) {
        if (!text) return '';
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Handle "Select all" and per-row checkboxes; expose selected IDs for future use.
     */
    function handleCheckboxSelection() {
        var $table = $('#usersTable');
        var $selectAll = $('#selectAll');
        var $checkboxes = $table.find('.user-select-cb');

        $selectAll.off('change').on('change', function () {
            var checked = $(this).prop('checked');
            $checkboxes.prop('checked', checked);
        });

        $checkboxes.off('change').on('change', function () {
            var total = $checkboxes.length;
            var checked = $checkboxes.filter(':checked').length;
            $selectAll.prop('checked', total > 0 && checked === total);
            $selectAll.prop('indeterminate', checked > 0 && checked < total);
        });

        $selectAll.prop('checked', false);
        $selectAll.prop('indeterminate', false);
    }

    /**
     * Get currently selected user IDs (for future Mass Password Delivery).
     */
    function getSelectedIds() {
        return $('#usersTable').find('.user-select-cb:checked').map(function () {
            return $(this).val();
        }).get();
    }

    function init(options) {
        if (options) {
            config.listUrl = options.listUrl || config.listUrl;
            config.filterByRoleUrl = options.filterByRoleUrl || config.filterByRoleUrl;
        }

        $('#btnFilter').on('click', function () {
            var role = $('#roleFilter').val() || '';
            filterByRole(role);
        });

        $('#btnReset').on('click', function () {
            $('#roleFilter').val('');
            $('#searchBox').val('');
            loadUsers();
        });

        $('#searchBox').on('keyup', function () {
            if (dataTable) {
                dataTable.search(this.value).draw();
            }
        });

        loadUsers();
    }

    return {
        init: init,
        loadUsers: loadUsers,
        filterByRole: filterByRole,
        handleCheckboxSelection: handleCheckboxSelection,
        getSelectedIds: getSelectedIds
    };
})();
