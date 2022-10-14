use std::{env, process::Command};

#[must_use]
pub struct Message {
    args: Vec<String>
}

impl Message {
    pub fn new() -> Self {
        Self { args: vec![] }
    }

    pub fn msg<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--msg".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn msg2<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--msg2".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn warning<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--warning".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn error<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--error".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn error2<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--error2".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn question<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--question".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn no_style<T: ToString>(mut self, msg: T) -> Self {
        self.args.push("--no-style".to_string());
        self.args.push(msg.to_string());
        self
    }

    pub fn send(self) {
        let mut _cmd = Command::new(env::var("MAKEDEB_BINARY").unwrap());
        let mut cmd = &mut _cmd;
        cmd = cmd.env("IN_MAKEDEB_RS", "1");

        cmd = cmd.args(self.args);

        cmd.spawn().unwrap().wait().unwrap();
    }
}