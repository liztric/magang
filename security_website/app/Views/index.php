<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Riwayat Laporan</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .action-btn {
            transition: transform 0.3s ease, opacity 0.3s ease;
        }

        .action-btn:hover {
            transform: scale(1.1);
            opacity: 0.8;
        }

        .action-btn:active {
            transform: scale(0.9);
            opacity: 0.6;
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
        <table class="table table-striped">
            <thead>
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">Nama</th>
                    <th scope="col">Alamat</th>
                    <th scope="col">Deskripsi</th>
                    <th scope="col">Category</th>
                    <th scope="col">Tanggal dan Waktu</th>
                    <th scope="col">Aksi</th> <!-- Kolom baru untuk aksi -->
                </tr>
            </thead>
            <tbody id="tbody">
                <!-- Data will be dynamically inserted here -->
            </tbody>
        </table>
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
                                <td>
                                    <img src="sampah.png" alt="Hapus" class="action-btn" style="cursor:pointer;" width="50" onclick="deleteData('${row[0]}')" />
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
                category: document.getElementById("category").value
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