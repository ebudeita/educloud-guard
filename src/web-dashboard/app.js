let findings = [];

const tableBody =
    document.getElementById("findingsTableBody");

const severityFilter =
    document.getElementById("severityFilter");

const categoryFilter =
    document.getElementById("categoryFilter");

const departmentFilter =
    document.getElementById("departmentFilter");

const clearFiltersButton =
    document.getElementById("clearFilters");

function updateSummary(data) {

    document.getElementById("openCount").textContent =
        data.filter(
            finding => finding.status === "OPEN"
        ).length;

    document.getElementById("highCount").textContent =
        data.filter(
            finding => finding.severity === "HIGH"
        ).length;

    document.getElementById("mediumCount").textContent =
        data.filter(
            finding => finding.severity === "MEDIUM"
        ).length;

    document.getElementById("lowCount").textContent =
        data.filter(
            finding => finding.severity === "LOW"
        ).length;


    document.getElementById("securityCount").textContent =
        data.filter(
            finding => finding.category === "SECURITY"
        ).length;

    document.getElementById("governanceCount").textContent =
        data.filter(
            finding => finding.category === "GOVERNANCE"
        ).length;

    document.getElementById("costCount").textContent =
        data.filter(
            finding => finding.category === "COST"
        ).length;
}


function severityClass(severity) {

    return `severity-${severity.toLowerCase()}`;
}


function statusClass(status) {

    return `status-${status.toLowerCase()}`;
}


function renderFindings(data) {

    tableBody.innerHTML = "";

    if (data.length === 0) {

        tableBody.innerHTML = `
            <tr>
                <td
                    colspan="6"
                    class="empty-state"
                >
                    No findings match the selected filters.
                </td>
            </tr>
        `;

        return;
    }


    data.forEach((finding, index) => {

        const row =
            document.createElement("tr");

        row.innerHTML = `
            <td>
                ${finding.control_id}
            </td>

            <td>
                <span
                    class="
                        severity-badge
                        ${severityClass(
                            finding.severity
                        )}
                    "
                >
                    ${finding.severity}
                </span>
            </td>

            <td>
                ${finding.department}
            </td>

            <td>
                ${finding.resource_name}
            </td>

            <td>
                <span
                    class="
                        status-badge
                        ${statusClass(
                            finding.status
                        )}
                    "
                >
                    ${finding.status}
                </span>
            </td>

            <td>
                <button
                    class="details-button"
                    data-index="${index}"
                >
                    View
                </button>
            </td>
        `;

        tableBody.appendChild(row);
    });


    document
        .querySelectorAll(".details-button")
        .forEach(button => {

            button.addEventListener(
                "click",
                () => {

                    const finding =
                        data[
                            Number(
                                button.dataset.index
                            )
                        ];

                    openModal(finding);
                }
            );
        });
}


function populateDepartments() {

    departmentFilter.innerHTML = `
        <option value="">
            All Departments
        </option>
    `;

    const departments =
        [
            ...new Set(
                findings.map(
                    finding =>
                        finding.department
                )
            )
        ].sort();


    departments.forEach(department => {

        const option =
            document.createElement("option");

        option.value = department;
        option.textContent = department;

        departmentFilter.appendChild(option);
    });
}


function applyFilters() {

    const severity =
        severityFilter.value;

    const category =
        categoryFilter.value;

    const department =
        departmentFilter.value;

    const filtered =
        findings.filter(finding => {

            if (
                severity &&
                finding.severity !== severity
            ) {
                return false;
            }

            if (
                category &&
                finding.category !== category
            ) {
                return false;
            }

            if (
                department &&
                finding.department !== department
            ) {
                return false;
            }

            return true;
        });


    renderFindings(filtered);
}


function openModal(finding) {

    document.getElementById(
        "modalControl"
    ).textContent =
        finding.control_id;

    document.getElementById(
        "modalSeverity"
    ).textContent =
        finding.severity;

    document.getElementById(
        "modalDepartment"
    ).textContent =
        finding.department;

    document.getElementById(
        "modalResource"
    ).textContent =
        finding.resource_name;

    document.getElementById(
        "modalDescription"
    ).textContent =
        finding.description;

    document.getElementById(
        "modalRecommendation"
    ).textContent =
        finding.recommendation;


    document
        .getElementById("findingModal")
        .classList.remove("hidden");
}


function closeModal() {

    document
        .getElementById("findingModal")
        .classList.add("hidden");
}


severityFilter.addEventListener(
    "change",
    applyFilters
);

categoryFilter.addEventListener(
    "change",
    applyFilters
);

departmentFilter.addEventListener(
    "change",
    applyFilters
);

clearFiltersButton.addEventListener(
    "click",
    () => {

        severityFilter.value = "";
        categoryFilter.value = "";
        departmentFilter.value = "";

        applyFilters();
    }
);

async function loadFindings() {

    try {

        const response =
            await fetch(
                "/api/findings?status=OPEN"
            );

        if (!response.ok) {
            throw new Error(
                `HTTP ${response.status}`
            );
        }

        const data =
            await response.json();

        findings =
            data.findings || [];

        populateDepartments();

        updateSummary(findings);

        renderFindings(findings);

        document.getElementById(
            "lastUpdated"
        ).textContent =
            new Date().toLocaleString();

    } catch (error) {

        console.error(
            "Unable to load findings:",
            error
        );

        tableBody.innerHTML = `
            <tr>
                <td
                    colspan="6"
                    class="empty-state"
                >
                    Unable to load live findings.
                </td>
            </tr>
        `;
    }
}

document
    .getElementById("closeModal")
    .addEventListener(
        "click",
        closeModal
    );


document
    .getElementById("findingModal")
    .addEventListener(
        "click",
        event => {

            if (
                event.target.id ===
                "findingModal"
            ) {
                closeModal();
            }
        }
    );


loadFindings();
