//
//  UriScheme.swift
//  StacleKit
//
//  Created by Gor Gyolchanyan on 11/8/19.
//  Copyright © 2019 Skytech Solutions. All rights reserved.
//

// MARK: - UriScheme

public struct UriScheme: RawRepresentable {

	// MARK: Protocol: RawRepresentable

	public typealias RawValue = String

	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	public let rawValue: RawValue
}

// MARK: Protocol: CustomStringConvertible

extension UriScheme: CustomStringConvertible {

	public var description: String { self.rawValue }
}

// MARK: Topic: Standard

extension UriScheme {

	// These values are taken from the [IANA URI Scheme Registry](https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml).

	// MARK: Topic: Permanent

	public static let aaa: Self = Self(rawValue: "aaa")

	public static let aaas: Self = Self(rawValue: "aaas")

	public static let about: Self = Self(rawValue: "about")

	public static let acap: Self = Self(rawValue: "acap")

	public static let acct: Self = Self(rawValue: "acct")

	public static let cap: Self = Self(rawValue: "cap")

	public static let cid: Self = Self(rawValue: "cid")

	public static let coap: Self = Self(rawValue: "coap")

	public static let coapTcp: Self = Self(rawValue: "coap+tcp")

	public static let coapWs: Self = Self(rawValue: "coap+ws")

	public static let coaps: Self = Self(rawValue: "coaps")

	public static let coapsTcp: Self = Self(rawValue: "coaps+tcp")

	public static let coapsWs: Self = Self(rawValue: "coaps+ws")

	public static let crid: Self = Self(rawValue: "crid")

	public static let data: Self = Self(rawValue: "data")

	public static let dav: Self = Self(rawValue: "dav")

	public static let dict: Self = Self(rawValue: "dict")

	public static let dns: Self = Self(rawValue: "dns")

	public static let example: Self = Self(rawValue: "example")

	public static let file: Self = Self(rawValue: "file")

	public static let ftp: Self = Self(rawValue: "ftp")

	public static let geo: Self = Self(rawValue: "geo")

	public static let go: Self = Self(rawValue: "go")

	public static let gopher: Self = Self(rawValue: "gopher")

	public static let h323: Self = Self(rawValue: "h323")

	public static let http: Self = Self(rawValue: "http")

	public static let https: Self = Self(rawValue: "https")

	public static let iax: Self = Self(rawValue: "iax")

	public static let icap: Self = Self(rawValue: "icap")

	public static let im: Self = Self(rawValue: "im")

	public static let imap: Self = Self(rawValue: "imap")

	public static let info: Self = Self(rawValue: "info")

	public static let ipp: Self = Self(rawValue: "ipp")

	public static let ipps: Self = Self(rawValue: "ipps")

	public static let iris: Self = Self(rawValue: "iris")

	public static let irisBeep: Self = Self(rawValue: "iris.beep")

	public static let irisLwz: Self = Self(rawValue: "iris.lwz")

	public static let irisXpc: Self = Self(rawValue: "iris.xpc")

	public static let irisXpcs: Self = Self(rawValue: "iris.xpcs")

	public static let jabber: Self = Self(rawValue: "jabber")

	public static let ldap: Self = Self(rawValue: "ldap")

	public static let leaptofrogans: Self = Self(rawValue: "leaptofrogans")

	public static let mailto: Self = Self(rawValue: "mailto")

	public static let mid: Self = Self(rawValue: "mid")

	public static let msrp: Self = Self(rawValue: "msrp")

	public static let msrps: Self = Self(rawValue: "msrps")

	public static let mtqp: Self = Self(rawValue: "mtqp")

	public static let mupdate: Self = Self(rawValue: "mupdate")

	public static let news: Self = Self(rawValue: "news")

	public static let nfs: Self = Self(rawValue: "nfs")

	public static let ni: Self = Self(rawValue: "ni")

	public static let nih: Self = Self(rawValue: "nih")

	public static let nntp: Self = Self(rawValue: "nntp")

	public static let opaquelocktoken: Self = Self(rawValue: "opaquelocktoken")

	public static let pkcs11: Self = Self(rawValue: "pkcs11")

	public static let pop: Self = Self(rawValue: "pop")

	public static let pres: Self = Self(rawValue: "pres")

	public static let reload: Self = Self(rawValue: "reload")

	public static let rtsp: Self = Self(rawValue: "rtsp")

	public static let rtsps: Self = Self(rawValue: "rtsps")

	public static let rtspu: Self = Self(rawValue: "rtspu")

	public static let service: Self = Self(rawValue: "service")

	public static let session: Self = Self(rawValue: "session")

	public static let shttp: Self = Self(rawValue: "shttp")

	public static let sieve: Self = Self(rawValue: "sieve")

	public static let sip: Self = Self(rawValue: "sip")

	public static let sips: Self = Self(rawValue: "sips")

	public static let sms: Self = Self(rawValue: "sms")

	public static let snmp: Self = Self(rawValue: "snmp")

	public static let soapBeep: Self = Self(rawValue: "soap.beep")

	public static let soapBeeps: Self = Self(rawValue: "soap.beeps")

	public static let stun: Self = Self(rawValue: "stun")

	public static let stuns: Self = Self(rawValue: "stuns")

	public static let tag: Self = Self(rawValue: "tag")

	public static let tel: Self = Self(rawValue: "tel")

	public static let telnet: Self = Self(rawValue: "telnet")

	public static let tftp: Self = Self(rawValue: "tftp")

	public static let thismessage: Self = Self(rawValue: "thismessage")

	public static let tip: Self = Self(rawValue: "tip")

	public static let tn3270: Self = Self(rawValue: "tn3270")

	public static let turn: Self = Self(rawValue: "turn")

	public static let turns: Self = Self(rawValue: "turns")

	public static let tv: Self = Self(rawValue: "tv")

	public static let urn: Self = Self(rawValue: "urn")

	public static let vemmi: Self = Self(rawValue: "vemmi")

	public static let vnc: Self = Self(rawValue: "vnc")

	public static let ws: Self = Self(rawValue: "ws")

	public static let wss: Self = Self(rawValue: "wss")

	public static let xcon: Self = Self(rawValue: "xcon")

	public static let xconUserid: Self = Self(rawValue: "xcon-userid")

	public static let xmlrpcBeep: Self = Self(rawValue: "xmlrpc.beep")

	public static let xmlrpcBeeps: Self = Self(rawValue: "xmlrpc.beeps")

	public static let xmpp: Self = Self(rawValue: "xmpp")

	public static let z39_50r: Self = Self(rawValue: "z39.50r")

	public static let z39_50s: Self = Self(rawValue: "z39.50s")

	// MARK: Topic: Provisional

	public static let acd: Self = Self(rawValue: "acd")

	public static let acr: Self = Self(rawValue: "acr")

	public static let adiumxtra: Self = Self(rawValue: "adiumxtra")

	public static let adt: Self = Self(rawValue: "adt")

	public static let afp: Self = Self(rawValue: "afp")

	public static let afs: Self = Self(rawValue: "afs")

	public static let aim: Self = Self(rawValue: "aim")

	public static let amss: Self = Self(rawValue: "amss")

	public static let android: Self = Self(rawValue: "android")

	public static let appdata: Self = Self(rawValue: "appdata")

	public static let apt: Self = Self(rawValue: "apt")

	public static let ark: Self = Self(rawValue: "ark")

	public static let attachment: Self = Self(rawValue: "attachment")

	public static let aw: Self = Self(rawValue: "aw")

	public static let barion: Self = Self(rawValue: "barion")

	public static let beshare: Self = Self(rawValue: "beshare")

	public static let bitcoin: Self = Self(rawValue: "bitcoin")

	public static let bitcoincash: Self = Self(rawValue: "bitcoincash")

	public static let blob: Self = Self(rawValue: "blob")

	public static let bolo: Self = Self(rawValue: "bolo")

	public static let browserext: Self = Self(rawValue: "browserext")

	public static let calculator: Self = Self(rawValue: "calculator")

	public static let callto: Self = Self(rawValue: "callto")

	public static let cast: Self = Self(rawValue: "cast")

	public static let casts: Self = Self(rawValue: "casts")

	public static let chrome: Self = Self(rawValue: "chrome")

	public static let chromeExtension: Self = Self(rawValue: "chrome-extension")

	public static let comEventbriteAttendee: Self = Self(rawValue: "com-eventbrite-attendee")

	public static let content: Self = Self(rawValue: "content")

	public static let conti: Self = Self(rawValue: "conti")

	public static let cvs: Self = Self(rawValue: "cvs")

	public static let dab: Self = Self(rawValue: "dab")

	public static let diaspora: Self = Self(rawValue: "diaspora")

	public static let did: Self = Self(rawValue: "did")

	public static let dis: Self = Self(rawValue: "dis")

	public static let dlnaPlaycontainer: Self = Self(rawValue: "dlna-playcontainer")

	public static let dlnaPlaysingle: Self = Self(rawValue: "dlna-playsingle")

	public static let dntp: Self = Self(rawValue: "dntp")

	public static let dpp: Self = Self(rawValue: "dpp")

	public static let drm: Self = Self(rawValue: "drm")

	public static let drop: Self = Self(rawValue: "drop")

	public static let dtn: Self = Self(rawValue: "dtn")

	public static let dvb: Self = Self(rawValue: "dvb")

	public static let ed2k: Self = Self(rawValue: "ed2k")

	public static let elsi: Self = Self(rawValue: "elsi")

	public static let facetime: Self = Self(rawValue: "facetime")

	public static let feed: Self = Self(rawValue: "feed")

	public static let feedready: Self = Self(rawValue: "feedready")

	public static let finger: Self = Self(rawValue: "finger")

	public static let firstRunPenExperience: Self = Self(rawValue: "first-run-pen-experience")

	public static let fish: Self = Self(rawValue: "fish")

	public static let fm: Self = Self(rawValue: "fm")

	public static let fuchsiaPkg: Self = Self(rawValue: "fuchsia-pkg")

	public static let gg: Self = Self(rawValue: "gg")

	public static let git: Self = Self(rawValue: "git")

	public static let gizmoproject: Self = Self(rawValue: "gizmoproject")

	public static let graph: Self = Self(rawValue: "graph")

	public static let gtalk: Self = Self(rawValue: "gtalk")

	public static let ham: Self = Self(rawValue: "ham")

	public static let hcap: Self = Self(rawValue: "hcap")

	public static let hcp: Self = Self(rawValue: "hcp")

	public static let hxxp: Self = Self(rawValue: "hxxp")

	public static let hxxps: Self = Self(rawValue: "hxxps")

	public static let hydrazone: Self = Self(rawValue: "hydrazone")

	public static let icon: Self = Self(rawValue: "icon")

	public static let iotdisco: Self = Self(rawValue: "iotdisco")

	public static let ipn: Self = Self(rawValue: "ipn")

	public static let irc: Self = Self(rawValue: "irc")

	public static let irc6: Self = Self(rawValue: "irc6")

	public static let ircs: Self = Self(rawValue: "ircs")

	public static let isostore: Self = Self(rawValue: "isostore")

	public static let itms: Self = Self(rawValue: "itms")

	public static let jar: Self = Self(rawValue: "jar")

	public static let jms: Self = Self(rawValue: "jms")

	public static let keyparc: Self = Self(rawValue: "keyparc")

	public static let lastfm: Self = Self(rawValue: "lastfm")

	public static let ldaps: Self = Self(rawValue: "ldaps")

	public static let lorawan: Self = Self(rawValue: "lorawan")

	public static let lvlt: Self = Self(rawValue: "lvlt")

	public static let magnet: Self = Self(rawValue: "magnet")

	public static let maps: Self = Self(rawValue: "maps")

	public static let market: Self = Self(rawValue: "market")

	public static let message: Self = Self(rawValue: "message")

	public static let microsoftWindowsCamera: Self = Self(rawValue: "microsoft.windows.camera")

	public static let microsoftWindowsCameraMultipicker: Self = Self(rawValue: "microsoft.windows.camera.multipicker")

	public static let microsoftWindowsCameraPicker: Self = Self(rawValue: "microsoft.windows.camera.picker")

	public static let mms: Self = Self(rawValue: "mms")

	public static let mongodb: Self = Self(rawValue: "mongodb")

	public static let moz: Self = Self(rawValue: "moz")

	public static let msAccess: Self = Self(rawValue: "ms-access")

	public static let msBrowserExtension: Self = Self(rawValue: "ms-browser-extension")

	public static let msCalculator: Self = Self(rawValue: "ms-calculator")

	public static let msDriveTo: Self = Self(rawValue: "ms-drive-to")

	public static let msEnrollment: Self = Self(rawValue: "ms-enrollment")

	public static let msExcel: Self = Self(rawValue: "ms-excel")

	public static let msEyecontrolspeech: Self = Self(rawValue: "ms-eyecontrolspeech")

	public static let msGamebarservices: Self = Self(rawValue: "ms-gamebarservices")

	public static let msGamingoverlay: Self = Self(rawValue: "ms-gamingoverlay")

	public static let msGetoffice: Self = Self(rawValue: "ms-getoffice")

	public static let msHelp: Self = Self(rawValue: "ms-help")

	public static let msInfopath: Self = Self(rawValue: "ms-infopath")

	public static let msInputapp: Self = Self(rawValue: "ms-inputapp")

	public static let msLockscreencomponentConfig: Self = Self(rawValue: "ms-lockscreencomponent-config")

	public static let msMediaStreamId: Self = Self(rawValue: "ms-media-stream-id")

	public static let msMixedrealitycapture: Self = Self(rawValue: "ms-mixedrealitycapture")

	public static let msMobileplans: Self = Self(rawValue: "ms-mobileplans")

	public static let msOfficeapp: Self = Self(rawValue: "ms-officeapp")

	public static let msPeople: Self = Self(rawValue: "ms-people")

	public static let msPowerpoint: Self = Self(rawValue: "ms-powerpoint")

	public static let msProject: Self = Self(rawValue: "ms-project")

	public static let msPublisher: Self = Self(rawValue: "ms-publisher")

	public static let msRestoretabcompanion: Self = Self(rawValue: "ms-restoretabcompanion")

	public static let msScreenclip: Self = Self(rawValue: "ms-screenclip")

	public static let msScreensketch: Self = Self(rawValue: "ms-screensketch")

	public static let msSearch: Self = Self(rawValue: "ms-search")

	public static let msSearchRepair: Self = Self(rawValue: "ms-search-repair")

	public static let msSecondaryScreenController: Self = Self(rawValue: "ms-secondary-screen-controller")

	public static let msSecondaryScreenSetup: Self = Self(rawValue: "ms-secondary-screen-setup")

	public static let msSettings: Self = Self(rawValue: "ms-settings")

	public static let msSettingsAirplanemode: Self = Self(rawValue: "ms-settings-airplanemode")

	public static let msSettingsBluetooth: Self = Self(rawValue: "ms-settings-bluetooth")

	public static let msSettingsCamera: Self = Self(rawValue: "ms-settings-camera")

	public static let msSettingsCellular: Self = Self(rawValue: "ms-settings-cellular")

	public static let msSettingsCloudstorage: Self = Self(rawValue: "ms-settings-cloudstorage")

	public static let msSettingsConnectabledevices: Self = Self(rawValue: "ms-settings-connectabledevices")

	public static let msSettingsDisplaysTopology: Self = Self(rawValue: "ms-settings-displays-topology")

	public static let msSettingsEmailAndAccounts: Self = Self(rawValue: "ms-settings-emailandaccounts")

	public static let msSettingsLanguage: Self = Self(rawValue: "ms-settings-language")

	public static let msSettingsLocation: Self = Self(rawValue: "ms-settings-location")

	public static let msSettingsLock: Self = Self(rawValue: "ms-settings-lock")

	public static let msSettingsNfcTransactions: Self = Self(rawValue: "ms-settings-nfctransactions")

	public static let msSettingsNotifications: Self = Self(rawValue: "ms-settings-notifications")

	public static let msSettingsPower: Self = Self(rawValue: "ms-settings-power")

	public static let msSettingsPrivacy: Self = Self(rawValue: "ms-settings-privacy")

	public static let msSettingsProximity: Self = Self(rawValue: "ms-settings-proximity")

	public static let msSettingsScreenrotation: Self = Self(rawValue: "ms-settings-screenrotation")

	public static let msSettingsWifi: Self = Self(rawValue: "ms-settings-wifi")

	public static let msSettingsWorkplace: Self = Self(rawValue: "ms-settings-workplace")

	public static let msSpd: Self = Self(rawValue: "ms-spd")

	public static let msSttoverlay: Self = Self(rawValue: "ms-sttoverlay")

	public static let msTransitTo: Self = Self(rawValue: "ms-transit-to")

	public static let msUseractivityset: Self = Self(rawValue: "ms-useractivityset")

	public static let msVirtualtouchpad: Self = Self(rawValue: "ms-virtualtouchpad")

	public static let msVisio: Self = Self(rawValue: "ms-visio")

	public static let msWalkTo: Self = Self(rawValue: "ms-walk-to")

	public static let msWhiteboard: Self = Self(rawValue: "ms-whiteboard")

	public static let msWhiteboardCmd: Self = Self(rawValue: "ms-whiteboard-cmd")

	public static let msWord: Self = Self(rawValue: "ms-word")

	public static let msnim: Self = Self(rawValue: "msnim")

	public static let mss: Self = Self(rawValue: "mss")

	public static let mumble: Self = Self(rawValue: "mumble")

	public static let mvn: Self = Self(rawValue: "mvn")

	public static let notes: Self = Self(rawValue: "notes")

	public static let ocf: Self = Self(rawValue: "ocf")

	public static let oid: Self = Self(rawValue: "oid")

	public static let onenote: Self = Self(rawValue: "onenote")

	public static let onenoteCmd: Self = Self(rawValue: "onenote-cmd")

	public static let openpgp4fpr: Self = Self(rawValue: "openpgp4fpr")

	public static let palm: Self = Self(rawValue: "palm")

	public static let paparazzi: Self = Self(rawValue: "paparazzi")

	public static let payto: Self = Self(rawValue: "payto")

	public static let platform: Self = Self(rawValue: "platform")

	public static let proxy: Self = Self(rawValue: "proxy")

	public static let psyc: Self = Self(rawValue: "psyc")

	public static let pttp: Self = Self(rawValue: "pttp")

	public static let pwid: Self = Self(rawValue: "pwid")

	public static let qb: Self = Self(rawValue: "qb")

	public static let query: Self = Self(rawValue: "query")

	public static let quicTransport: Self = Self(rawValue: "quic-transport")

	public static let redis: Self = Self(rawValue: "redis")

	public static let rediss: Self = Self(rawValue: "rediss")

	public static let res: Self = Self(rawValue: "res")

	public static let resource: Self = Self(rawValue: "resource")

	public static let rmi: Self = Self(rawValue: "rmi")

	public static let rsync: Self = Self(rawValue: "rsync")

	public static let rtmfp: Self = Self(rawValue: "rtmfp")

	public static let rtmp: Self = Self(rawValue: "rtmp")

	public static let secondlife: Self = Self(rawValue: "secondlife")

	public static let sftp: Self = Self(rawValue: "sftp")

	public static let sgn: Self = Self(rawValue: "sgn")

	public static let simpleledger: Self = Self(rawValue: "simpleledger")

	public static let skype: Self = Self(rawValue: "skype")

	public static let smb: Self = Self(rawValue: "smb")

	public static let smtp: Self = Self(rawValue: "smtp")

	public static let soldat: Self = Self(rawValue: "soldat")

	public static let spiffe: Self = Self(rawValue: "spiffe")

	public static let spotify: Self = Self(rawValue: "spotify")

	public static let ssh: Self = Self(rawValue: "ssh")

	public static let steam: Self = Self(rawValue: "steam")

	public static let submit: Self = Self(rawValue: "submit")

	public static let svn: Self = Self(rawValue: "svn")

	public static let teamspeak: Self = Self(rawValue: "teamspeak")

	public static let teliaeid: Self = Self(rawValue: "teliaeid")

	public static let things: Self = Self(rawValue: "things")

	public static let tool: Self = Self(rawValue: "tool")

	public static let udp: Self = Self(rawValue: "udp")

	public static let unreal: Self = Self(rawValue: "unreal")

	public static let ut2004: Self = Self(rawValue: "ut2004")

	public static let vEvent: Self = Self(rawValue: "v-event")

	public static let ventrilo: Self = Self(rawValue: "ventrilo")

	public static let viewSource: Self = Self(rawValue: "view-source")

	public static let webcal: Self = Self(rawValue: "webcal")

	public static let wtai: Self = Self(rawValue: "wtai")

	public static let wyciwyg: Self = Self(rawValue: "wyciwyg")

	public static let xfire: Self = Self(rawValue: "xfire")

	public static let xri: Self = Self(rawValue: "xri")

	public static let ymsgr: Self = Self(rawValue: "ymsgr")

	// MARK: Topic: Historical

	public static let fax: Self = Self(rawValue: "fax")

	public static let filesystem: Self = Self(rawValue: "filesystem")

	public static let mailserver: Self = Self(rawValue: "mailserver")

	public static let modem: Self = Self(rawValue: "modem")

	public static let pack: Self = Self(rawValue: "pack")

	public static let prospero: Self = Self(rawValue: "prospero")

	public static let snews: Self = Self(rawValue: "snews")

	public static let videotex: Self = Self(rawValue: "videotex")

	public static let wais: Self = Self(rawValue: "wais")

	public static let wpid: Self = Self(rawValue: "wpid")

	public static let z39_50: Self = Self(rawValue: "z39.50")
}
