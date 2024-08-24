<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Riwayat Laporan</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f7f7f7;
            font-family: Arial, sans-serif;
        }

        .navbar-dark .navbar-nav .nav-link {
            font-size: 18px;
            font-weight: 500;
        }

        h2 {
            color: #333;
        }

        .table {
            background-color: #fff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
        }

        .table th, .table td {
            vertical-align: middle;
        }

        .table-hover tbody tr:hover {
            background-color: #f1f1f1;
        }

        .action-btn {
            transition: transform 0.3s ease, opacity 0.3s ease;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            border: none;
            background-color: transparent;
        }

        .action-btn img {
            max-width: 24px;
        }

        .action-btn:hover {
            transform: scale(1.2);
            opacity: 0.8;
        }

        .action-btn:active {
            transform: scale(0.9);
            opacity: 0.6;
        }

        .container {
            margin-top: 50px;
        }

        .table th {
            background-color: #007bff;
            color: #fff;
            text-align: center;
        }

        .table td {
            text-align: center;
        }

        .table td img {
            width: 30px;
            cursor: pointer;
        }
    </style>
</head>

<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <div class="collapse navbar-collapse" id="navbarNavDropdown">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="index">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="register">Register</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="daftaruser">Daftar Pengguna</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-5">
        <h2 class="text-center mb-4">Dashboard Riwayat Laporan</h2>
        <div class="table-responsive">
            <table class="table table-hover table-striped">
                <thead>
                    <tr>
                        <th scope="col">#</th>
                        <th scope="col">Nama</th>
                        <th scope="col">Alamat</th>
                        <th scope="col">Deskripsi</th>
                        <th scope="col">Category</th>
                        <th scope="col">Tanggal dan Waktu</th>
                        <th scope="col">Status</th> <!-- Tambahkan kolom Status -->
                        <th scope="col">Aksi</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                    <!-- Data will be dynamically inserted here -->
                </tbody>
            </table>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        const authKey = "05xW10cmdxUBIBwXw4i5edLZy06MbpMRelL5QGf2";
        const databaseUrl = `https://esolusindosecurity-default-rtdb.firebaseio.com/laporan.json?auth=${authKey}`;

        let tbody = document.getElementById("tbody");

        document.addEventListener("DOMContentLoaded", function() {
            getData();
        });

        function getData() {
            fetch(databaseUrl)
                .then((res) => res.json())
                .then((data) => {
                    let tabel = "";
                    let no = 1;
                    let entries = Object.entries(data || {}).slice(1);

                    entries.forEach((row) => {
                        if (row[1]) {
                            tabel += `
                            <tr>
                                <td>${no}</td>
                                <td>${row[1].nama || '-'}</td>
                                <td>${row[1].alamat || '-'}</td>
                                <td>${row[1].deskripsi || '-'}</td>
                                <td>${row[1].category || '-'}</td>
                                <td>${row[1].tanggal || '-'} ${row[1].waktu || '-'}</td>
                                <td>${row[1].status || '-'}</td> <!-- Tambahkan data Status -->
                                <td>
                                    <button class="action-btn" onclick="deleteData('${row[0]}')">
                                        <img src="sampah.png" alt="Hapus" />
                                    </button>
                                </td>
                            </tr>
                            `;
                            no++;
                        }
                    });

                    tbody.innerHTML = tabel;
                })
                .catch((error) => {
                    console.error('Error fetching data:', error);
                });
        }

        function deleteData(id) {
            fetch(`https://esolusindosecurity-default-rtdb.firebaseio.com/laporan/${id}.json?auth=${authKey}`, {
                    method: "DELETE"
                })
                .then(() => {
                    getData(); // Refresh the data
                })
                .catch((error) => {
                    console.error('Error deleting data:', error);
                });
        }

        function createData() {
            let now = new Date();
            let data = {
                nama: document.getElementById("nama").value,
                alamat: document.getElementById("alamat").value,
                deskripsi: document.getElementById("deskripsi").value,
                tanggal: now.toISOString().split('T')[0], // Simpan tanggal saja dalam format YYYY-MM-DD
                waktu: now.toTimeString().split(' ')[0], // Simpan waktu saja dalam format HH:MM:SS
                category: document.getElementById("category").value,
                status: "Pending" // Tambahkan status default jika diperlukan
            };

            fetch(databaseUrl, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(data)
                })
                .then(() => {
                    document.getElementById("registerForm").reset();
                    getData(); // Refresh the data
                })
                .catch((error) => {
                    console.error('Error creating data:', error);
                });
        }
    </script>
</body>

</html>
