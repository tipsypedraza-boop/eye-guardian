#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

#[tauri::command]
fn close_app(app: tauri::AppHandle) {
    app.exit(0);
}

#[tauri::command]
fn start_idle_watcher() {
    // Simplified version - just a placeholder
    println!("Idle watcher started");
}

#[tauri::command]
fn record_break_start() {
    println!("Break started at {:?}", std::time::SystemTime::now());
}

#[tauri::command]
fn get_running_apps() -> Vec<String> {
    #[cfg(target_os = "windows")]
    {
        use std::process::Command;
        
        let output = Command::new("tasklist")
            .arg("/FO")
            .arg("CSV")
            .arg("/NH")
            .output();
        
        if let Ok(output) = output {
            let stdout = String::from_utf8_lossy(&output.stdout);
            return stdout
                .lines()
                .filter_map(|line| {
                    line.split(',')
                        .next()
                        .map(|s| s.trim_matches('"').to_lowercase())
                })
                .collect();
        }
    }
    
    Vec::new()
}

#[tauri::command]
fn check_fullscreen_app() -> bool {
    false
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            close_app,
            start_idle_watcher, 
            record_break_start,
            get_running_apps,
            check_fullscreen_app
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
