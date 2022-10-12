macro_rules! msg_fn {
    ($fn:ident) => {
        pub fn $fn<T: AsRef<str>>(args: &[T]) {
            let str_args = args.iter().map(|string| string.as_ref()).collect::<Vec<&str>>();
            let mut _cmd = std::process::Command::new(std::env::var("MAKEDEB_BINARY").unwrap());
            let mut cmd = &mut _cmd;

            for arg in str_args {
                cmd = cmd.args(["--".to_string() + stringify!($fn), arg.to_string()]);
            }

            cmd.spawn().unwrap().wait().unwrap();
        }
    }
}

msg_fn!(msg);
msg_fn!(msg2);
msg_fn!(warning);
msg_fn!(error);
msg_fn!(error2);
msg_fn!(question);
