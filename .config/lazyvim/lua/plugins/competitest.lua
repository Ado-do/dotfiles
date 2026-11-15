return {
  "xeluxee/competitest.nvim",
  dependencies = "MunifTanjim/nui.nvim",
  cmd = "CompetiTest",
  opts = {
    save_current_file = true,

    -- compile_directory = "build",
    compile_command = { cpp = { exec = "clang++", args = { "-Wall", "$(FNAME)", "-o", "build/$(FNOEXT)" } } },

    running_directory = "build",
    -- run_command = { cpp = { exec = "$(FNOEXT)" } },

    testcases_use_single_file = true,
    testcases_directory = "testcases",

    received_problems_path = "$(JAVA_TASK_CLASS).$(FEXT)",
    received_problems_prompt_path = true,
    received_contests_problems_path = "$(JAVA_TASK_CLASS).$(FEXT)",
  },
  keys = {
    { "<leader>Cu", "<cmd>CompetiTest show_ui<cr>", desc = "show ui", ft = "cpp" },
    { "<leader>Ct", "<cmd>CompetiTest run<cr>", desc = "run (compile)", ft = "cpp" },
    { "<leader>CT", "<cmd>CompetiTest run_no_compile<cr>", desc = "run (no compile)", ft = "cpp" },
    { "<leader>Cr", "", desc = "+receive" },
    { "<leader>Crt", "<cmd>CompetiTest receive testcases<cr>", desc = "receive testcases" },
    { "<leader>Crp", "<cmd>CompetiTest receive problem<cr>", desc = "receive problem" },
    { "<leader>Crc", "<cmd>CompetiTest receive contest<cr>", desc = "receive contest" },
    { "<leader>Crr", "<cmd>CompetiTest receive persistently<cr>", desc = "receive persistently" },
    { "<leader>Crs", "<cmd>CompetiTest receive stop<cr>", desc = "receive stop" },
  },
}
