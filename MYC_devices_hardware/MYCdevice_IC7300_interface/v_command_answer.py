""""
name: v_command_answer.py
last edited: 2019312
list for command and answers
"""

from commands import *
from answers import  *

command = {     256: command_frequency,
                257: answercommand,
                258: command_mode,
                259: answercommand,
                260: answercommand,
                261: command_set_vfo,
                262: command_vfo_mode,
                263: command_set_memory,
                264: command_sel_memory,
                265: command_ou,
                266: command_ou,
                267: command_ou,
                268: command_scan_mode,
                269: command_1_n_7_161,
                270: command_ou,
                271: command_1_b_3,
                272: command_1_b_4,
                273: command_scan_resume,
                274: command_1_b_2,
                275: answercommand,
                276: command_1_b_9,
                277: answercommand,
                278: command_att,
                279: answercommand,
                280: command_1_b_3,
                281: command_1_b_256_0_2,
                282: answercommand,
                283: command_1_b_256_0_2,
                284: answercommand,
                285: command_1_b_256_0_2,
                286: answercommand,
                287: command_1_b_256_0_2,
                288: answercommand,
                289: command_1_b_256_0_2,
                290: answercommand,
                291: command_1_b_256_0_2,
                292: answercommand,
                293: command_1_b_256_0_2,
                294: answercommand,
                295: command_1_b_256_0_2,
                296: answercommand,
                297: command_1_b_256_0_2,
                298: answercommand,
                299: command_1_b_256_0_2,
                300: answercommand,
                301: command_1_b_256_0_2,
                302: answercommand,
                303: command_1_b_256_0_2,
                304: answercommand,
                305: command_1_b_256_0_2,
                306: answercommand,
                307: command_1_b_256_0_2,
                308: answercommand,
                309: command_1_b_256_0_2,
                310: answercommand,
                311: command_1_b_256_0_2,
                312: answercommand,
                313: command_1_b_256_0_2,
                314: answercommand,
                315: command_1_b_256_0_2,
                316: answercommand,
                317: answercommand,
                318: answercommand,
                319: answercommand,
                320: answercommand,
                321: answercommand,
                322: answercommand,
                323: answercommand,
                324: answercommand,
                325: answercommand,
                326: command_1_b_3,
                327: answercommand,
                328: command_1_b_3_1,
                329: answercommand,
                330: command_1_b_2,
                331: answercommand,
                332: command_1_b_2,
                333: answercommand,
                334: command_1_b_2,
                335: answercommand,
                336: command_1_b_2,
                337: answercommand,
                338: command_1_b_2,
                339: answercommand,
                340: command_1_b_2,
                341: answercommand,
                342: command_1_b_2,
                343: answercommand,
                344: command_1_b_2,
                345: answercommand,
                346: command_1_b_3,
                347: answercommand,
                348: command_1_b_2,
                349: answercommand,
                350: command_1_b_2,
                351: answercommand,
                352: command_1_b_2,
                353: answercommand,
                354: command_1_b_2,
                355: answercommand,
                356: command_1_b_3,
                357: answercommand,
                358: command_1_b_3,
                359: answercommand,
                360: command_cw_text,
                361: command_on,
                362: answercommand00,
                363: command_memory_keyer,
                364: answercommand_1_8,
                365: command_filter_bw_am,
                366: answercommand_am,
                367: command_filter_bw_non_am,
                368: answercommand_non_am,
                369: command_agc_am,
                370: answercommand_am,
                371: command_agc_non_am,
                372: answercommand_non_am,
                373: command_hpf_lpf,
                374: answercommand,
                375: command_1_b_11,
                376: answercommand,
                377: command_1_b_11,
                378: answercommand,
                379: command_hpf_lpf,
                380: answercommand,
                381: command_1_b_11,
                382: answercommand,
                383: command_1_b_11,
                384: answercommand,
                385: command_hpf_lpf,
                386: answercommand,
                387: command_1_b_11,
                388: answercommand,
                389: command_1_b_11,
                390: answercommand,
                391: command_hpf_lpf,
                392: answercommand,
                393: command_hpf_lpf,
                394: answercommand,
                395: command_1_b_11,
                396: answercommand,
                397: command_1_b_11,
                398: answercommand,
                399: command_2_b_4,
                400: answercommand,
                401: command_2_b_4,
                402: answercommand,
                403: command_2_b_4,
                404: answercommand,
                405: command_1_b_11,
                406: answercommand,
                407: command_1_b_11,
                408: answercommand,
                409: command_1_b_11,
                410: answercommand,
                411: command_1_b_11,
                412: answercommand,
                413: command_1_b_256_0_2,
                414: answercommand,
                415: command_1_b_2,
                416: answercommand,
                417: command_1_b_2,
                418: answercommand,
                419: command_1_b_4,
                420: answercommand,
                421: command_1_b_3,
                422: answercommand,
                423: command_1_b_6,
                424: answercommand,
                425: command_1_b_6,
                426: answercommand,
                427: command_1_b_6,
                428: answercommand,
                429: command_1_b_6,
                430: answercommand,
                431: command_1_b_2,
                432: answercommand,
                433: command_offset_frequenz,
                434: answercommand,
                435: command_offset_frequenz,
                436: answercommand,
                437: command_1_b_2,
                438: answercommand,
                439: command_1_b_2,
                440: answercommand,
                441: command_1_b_2,
                442: answercommand,
                443: command_1_b_3,
                444: answercommand,
                445: command_1_b_3,
                446: answercommand,
                447: command_1_b_2,
                448: answercommand,
                449: command_1_b_2,
                450: answercommand,
                451: command_1_b_2,
                452: answercommand,
                453: command_1_b_2,
                454: answercommand,
                455: command_1_b_2,
                456: answercommand,
                457: command_1_b_256_0_2,
                458: answercommand,
                459: command_1_b_2,
                460: answercommand,
                461: command_1_b_2,
                462: answercommand,
                463: command_1_b_2,
                464: answercommand,
                465: command_1_b_3,
                466: answercommand,
                467: command_1_b_2,
                468: answercommand,
                469: command_1_b_2,
                470: answercommand,
                471: command_1_b_3,
                472: answercommand,
                473: command_1_b_3,
                474: answercommand,
                475: command_1_b_2,
                476: answercommand,
                477: command_1_b_2,
                478: answercommand,
                479: command_1_b_2,
                480: answercommand,
                481: command_1_b_2,
                482: answercommand,
                483: command_1_b_2,
                484: answercommand,
                485: command_1_b_2,
                486: answercommand,
                487: command_1_b_256_0_2,
                488: answercommand,
                489: command_1_b_2,
                490: answercommand,
                491: command_1_b_256_0_2,
                492: answercommand,
                493: command_1_b_2,
                494: answercommand,
                495: command_1_b_2,
                496: answercommand,
                497: command_1_b_256_0_2,
                498: answercommand,
                499 :command_1_b_256_0_2,
                500: answercommand,
                501: command_1_b_256_0_2,
                502: answercommand,
                503: command_1_b_4,
                504: answercommand,
                505: command_1_b_4,
                506: answercommand,
                507: command_1_b_2,
                508: answercommand,
                509: command_1_b_2,
                510: answercommand,
                511: command_1_b_2,
                512: answercommand,
                513: command_1_b_2,
                514: answercommand,
                515: command_1_b_224_0_2,
                516: answercommand,
                517: command_1_b_2,
                518: answercommand,
                519: nop,
                520: answercommand,
                521: command_1_b_2,
                522: answercommand,
                523: command_1_b_2,
                524: answercommand,
                525: command_1_b_4,
                526: answercommand,
                527: command_1_b_3,
                528: answercommand,
                529: command_1_b_3,
                530: answercommand,
                531: command_1_b_3,
                532: answercommand,
                533: command_1_b_256_0_2,
                534: answercommand,
                535: command_1_b_2,
                536: answercommand,
                537: command_1_b_2,
                538: answercommand,
                539: command_1_b_2,
                540: answercommand,
                541: command_1_b_2,
                542: answercommand,
                543: command_1_b_2,
                544: answercommand,
                545: command_1_b_2,
                546: answercommand,
                547: command_1_b_2,
                548: answercommand,
                549: command_1_b_4,
                550: answercommand,
                551: command_1_b_2,
                552: answercommand,
                553: command_string10,
                554: answercommand,
                555: command_1_b_2,
                556: answercommand,
                557: command_1_b_2,
                558: answercommand,
                559: command_date,
                560: answercommand,
                561: command_time,
                562: answercommand,
                563: command_utc,
                564: answercommand,
                565: command_1_b_2,
                566: answercommand,
                567: command_1_b_3,
                568: answercommand,
                569: command_1_b_3,
                570: answercommand,
                571: command_1_b_2,
                572: answercommand,
                573: command_1_b_2,
                574: answercommand,
                575: command_1_b_4,
                576: answercommand,
                577: command_1_b_2,
                578: answercommand,
                579: command_color,
                580: answercommand,
                581: command_color,
                582: answercommand,
                583: command_color,
                584: answercommand,
                585: command_1_b_2,
                586: answercommand,
                587: command_1_b_3,
                588: answercommand,
                589: command_1_b_3,
                590: answercommand,
                591: command_1_b_8,
                592: answercommand,
                593: command_1_b_2,
                594: answercommand,
                595: command_scope_edge_xx,
                596: answercommand_scope_edge_1,
                597: command_scope_edge_xx,
                598: answercommand_scope_edge_1,
                599: command_scope_edge_xx,
                600: answercommand_scope_edge_1,
                601: command_scope_edge_xx,
                602: answercommand_scope_edge_1,
                603: command_scope_edge_xx,
                604: answercommand_scope_edge_1,
                605: command_scope_edge_xx,
                606: answercommand_scope_edge_1,
                607: command_scope_edge_xx,
                608: answercommand_scope_edge_1,
                609: command_scope_edge_xx,
                610: answercommand_scope_edge_1,
                611: command_scope_edge_xx,
                612: answercommand_scope_edge_1,
                613: command_scope_edge_xx,
                614: answercommand_scope_edge_1,
                615: command_scope_edge_xx,
                616: answercommand_scope_edge_1,
                617: command_scope_edge_xx,
                618: answercommand_scope_edge_1,
                619: command_scope_edge_xx,
                620: answercommand_scope_edge_1,
                621: command_1_b_2,
                622: answercommand,
                623: command_color,
                624: answercommand,
                625: command_1_b_2,
                626: answercommand,
                627: command_color,
                628: answercommand,
                629: command_1_b_5,
                630: answercommand,
                631: command_1_b_8_1,
                632: answercommand,
                633: command_2_b_9999,
                634: answercommand,
                635: command_1_b_256_0_2,
                636: answercommand,
                637: command_1_b_2,
                638: answercommand,
                639: command_1_b_60_1,
                640: answercommand,
                641: command_1_b_18_28,
                642: answercommand,
                643: command_1_b_4,
                644: answercommand,
                645: command_1_b_2,
                646: answercommand,
                647: command_1_b_3,
                648: answercommand,
                649: command_1_b_2,
                650: answercommand,
                651: command_1_b_4,
                652: answercommand,
                653: command_color,
                654: answercommand,
                655: command_1_b_2,
                656: answercommand,
                657: command_1_b_2,
                658: answercommand,
                659: command_1_b_2,
                660: answercommand,
                661: command_color,
                662: answercommand,
                663: command_color,
                664: answercommand,
                665: command_1_b_2,
                666: answercommand,
                667: command_1_b_2,
                668: answercommand,
                669: command_1_b_2,
                670: answercommand,
                671: command_1_b_2,
                672: answercommand,
                673: command_1_b_2,
                674: answercommand,
                675: command_1_b_2,
                676: answercommand,
                677: command_1_b_2,
                678: answercommand,
                679: command_1_b_2,
                680: answercommand,
                681: command_1_b_15_1,
                682: answercommand,
                683: command_1_b_2,
                684: answercommand,
                685: command_1_b_2,
                686: answercommand,
                687: command_1_b_2,
                688: answercommand,
                689: command_1_b_2,
                690: answercommand,
                691: command_1_b_2,
                692: answercommand,
                693: command_1_b_4,
                694: answercommand,
                695: command_1_b_4,
                696: answercommand,
                697: command_1_b_10,
                698: answercommand,
                699: command_1_b_256_0_2,
                700: answercommand,
                701: command_1_b_21,
                702: answercommand,
                703: command_1_b_4,
                704: answercommand,
                705: command_1_b_2,
                706: answercommand,
                707: command_data_mode,
                708: answercommand,
                709: command_1_b_2,
                710: answercommand,
                711: command_tone_frequency,
                712: answercommand,
                713: command_tone_frequency,
                714: answercommand,
                715: command_1_b_2,
                716: answercommand,
                717: command_1_b_3,
                718: answercommand,
                719: command_1_b_2,
                720: answercommand,
                721: answercommand,
                722: command_1_b_2,
                723: answercommand,
                724: answercommand,
                725: answercommand_1_30,
                726: answercommand,
                727: command_scope_edge_xx,
                728: answercommand_1_30,
                729: command_rit,
                730: answercommand,
                731: command_1_b_2,
                732: answercommand,
                733: command_1_b_2,
                734: answercommand,
                735: command_frequency_u_sel,
                736: answercommand_1_2,
                737: command_mode_data_filter,
                738: answercommand_1_2,
                739: nop,
                740: command_1_b_2,
                741: answercommand,
                742: command_1_b_2,
                743: answercommand,
                744: answercommand,
                745: answercommand,
                746: command_1_b_2_0_2,
                747: answercommand00,
                748: command_scope_span,
                749: answercommand00,
                750: command_1_b_3_1_2,
                751: answercommand00,
                752: command_1_b_2_0_2,
                753: answercommand00,
                754: command_scope_reference_level,
                755: answercommand00,
                756: command_1_b_3_0_2,
                757: answercommand00,
                758: command_1_b_2,
                759: answercommand,
                760: command_1_b_3,
                761: answercommand,
                762: command_1_b_2_0_2,
                763: answercommand00,
                764: command_memory_frequency,
                765: answercommand_memory,
                766: command_memory_mode,
                767: answercommand_memory,
                768: command_memory_filter,
                769: answercommand_memory,
                770: command_memory_tone,
                771: answercommand_memory,
                772: command_memory_data_mode,
                773: answercommand_memory,
                774: command_memory_tone_frequency,
                775: answercommand_memory,
                776: command_memory_tone_squelch,
                777: answercommand_memory,
                778: command_memory_frequency_split,
                779: answercommand_memory,
                780: command_memory_mode_split,
                781: answercommand_memory,
                782: command_memory_filter_split,
                783: answercommand_memory,
                784: command_memory_tone_split,
                785: answercommand_memory,
                786: command_memory_data_mode_split,
                787: answercommand_memory,
                788: command_memory_tone_frequency_split,
                789: answercommand_memory,
                790: command_memory_tone_squelch_split,
                791: answercommand_memory,
                792: command_memory_name,
                793: answercommand_memory,
                794: answercommand_band_stack,
                795: command_copy_band_stack,
                65520: com240,
                65532: com252,
                65533: com253,
                65534: com254,
                65535: com255,
           }

# answer civ-commands < 20 (0x14)
answer = {0: answer_frequency_tranceive,
            1: answer_mode_filter4,
            2: answer_band_edge,
            3: answer_frequency,
            4: answer_mode_filter4,
            5: answer_frequency,
            15: answer_1_1_b,
            16: answer_1_1_b,
            17: answer_att,
          }

# answer civ-commands == 20 (0x14)
answer14 = { 1: answer_2_2_b_0_1,
            2: answer_2_2_b_0_1,
            3: answer_2_2_b_0_1,
            4: answer_2_2_b_0_1,
            5: answer_2_2_b_0_1,
            6: answer_2_2_b_0_1,
            7: answer_2_2_b_0_1,
            8: answer_2_2_b_0_1,
            9: answer_2_2_b_0_1,
            10: answer_2_2_b_0_1,
            11: answer_2_2_b_0_1,
            12: answer_2_2_b_0_1,
            13: answer_2_2_b_0_1,
            14: answer_2_2_b_0_1,
            15: answer_2_2_b_0_1,
            18: answer_2_2_b_0_1,
            21: answer_2_2_b_0_1,
            22: answer_2_2_b_0_1,
            23: answer_2_2_b_0_1,
            25: answer_2_2_b_0_1
}

# answer civ-commands == 21 (0x15)
answer15 = { 1: answer_2_1_b,
            2: answer_2_2_b_0_1,
            5: answer_2_1_b,
            17: answer_2_2_b_0_1,
            18: answer_2_2_b_0_1,
            19: answer_2_2_b_0_1,
            20: answer_2_2_b_0_1,
            21: answer_2_2_b_0_1,
            22: answer_2_2_b_0_1
}

# answer civ-commands == 22 (0x16)
answer16 = {2:  answer_2_1_b,
            18: answer_2_1_b,
            34: answer_2_1_b,
            64: answer_2_1_b,
            65: answer_2_1_b,
            66: answer_2_1_b,
            67: answer_2_1_b,
            68: answer_2_1_b,
            69: answer_2_1_b,
            70: answer_2_1_b,
            71: answer_2_1_b,
            72: answer_2_1_b,
            79: answer_2_1_b,
            80: answer_2_1_b,
            86: answer_2_1_b,
            87: answer_2_1_b,
            88: answer_2_1_b
}

# answer civ-commands == 0x1a00 - 0x1a04)
answer1a = {0x0: answer_memory_content,
                0x01: answer_band_stack,
                0x02: answer_memory_keyer,
                0x03: answer_2_1_b,
                0x04: answer_2_1_b,
                }
# answer civ-commands == 0x1a0500)
answer1a0500 = {0x01: answer_hpf_lpf,
                0x02: answer_4_1_b,
                0x03: answer_4_1_b,
                0x04: answer_hpf_lpf,
                0x05: answer_4_1_b,
                0x06: answer_4_1_b,
                0x07: answer_hpf_lpf,
                0x08: answer_4_1_b,
                0x09: answer_4_1_b,
                0x10: answer_hpf_lpf,
                0x11: answer_hpf_lpf,
                0x12: answer_4_1_b,
                0x13: answer_4_1_b,
                0x14: answer_ssb_passband,
                0x15: answer_ssb_passband,
                0x16: answer_ssb_passband,
                0x17: answer_4_1_b,
                0x18: answer_4_1_b,
                0x19: answer_4_1_b,
                0x20: answer_4_1_b,
                0x21: answer_4_2_b_0,
                0x22: answer_4_1_b,
                0x23: answer_4_1_b,
                0x24: answer_4_1_b,
                0x25: answer_4_1_b,
                0x26: answer_4_1_b,
                0x27: answer_4_1_b,
                0x28: answer_4_1_b,
                0x29: answer_4_1_b,
                0x30: answer_4_1_b,
                0x31: answer_offset,
                0x32: answer_offset,
                0x33: answer_4_1_b,
                0x34: answer_4_1_b,
                0x35: answer_4_1_b,
                0x36: answer_4_1_b,
                0x37: answer_4_1_b,
                0x38: answer_4_1_b,
                0x39: answer_4_1_b,
                0x40: answer_4_1_b,
                0x41: answer_4_1_b,
                0x42: answer_4_1_b,
                0x43: answer_4_2_b_0_1,
                0x44: answer_4_1_b,
                0x45: answer_4_1_b,
                0x46: answer_4_1_b,
                0x47: answer_4_1_b,
                0x48: answer_4_1_b,
                0x49: answer_4_1_b,
                0x50: answer_4_1_b,
                0x51: answer_4_1_b,
                0x52: answer_4_1_b,
                0x53: answer_4_1_b,
                0x54: answer_4_1_b,
                0x55: answer_4_1_b,
                0x56: answer_4_1_b,
                0x57: answer_4_1_b,
                0x58: answer_4_2_b_0_1,
                0x59: answer_4_1_b,
                0x60: answer_4_2_b_0_1,
                0x61: answer_4_1_b,
                0x62: answer_4_1_b,
                0x63: answer_4_2_b_0_1,
                0x64: answer_4_2_b_0_1,
                0x65: answer_4_2_b_0_1,
                0x66: answer_4_1_b,
                0x67: answer_4_1_b,
                0x68: answer_4_1_b,
                0x69: answer_4_1_b,
                0x70: answer_4_1_b,
                0x71: answer_4_1_b,
                0x72: answer_4_2_b_0_1,
                0x73: answer_4_1_b,
                0x74: answer_4_1_b,
                0x75: answer_4_1_b,
                0x76: answer_4_1_b,
                0x77: answer_4_1_b,
                0x78: answer_4_1_b,
                0x79: answer_4_1_b,
                0x80: answer_4_1_b,
                0x81: answer_4_2_b_0_1,
                0x82: answer_4_1_b,
                0x83: answer_4_1_b,
                0x84: answer_4_1_b,
                0x85: answer_4_1_b,
                0x86: answer_4_1_b,
                0x87: answer_4_1_b,
                0x88: answer_4_1_b,
                0x89: answer_4_1_b,
                0x90: answer_4_1_b,
                0x91: answer_string,
                0x92: answer_4_1_b,
                0x93: answer_4_1_b,
                0x94: answer_date,
                0x95: answer_time,
                0x96: answer_utc,
                0x97: answer_4_1_b,
                0x98: answer_4_1_b,
                0x99: answer_4_1_b,
               }

# answer civ-commands == 0x1a0501
answer1a0501 = {0x00: answer_4_1_b,
                0x01: answer_4_1_b,
                0x02: answer_4_1_b,
                0x03: answer_4_1_b,
                0x04: answer_color,
                0x05: answer_color,
                0x06: answer_color,
                0x07: answer_4_1_b,
                0x08: answer_4_1_b,
                0x09: answer_4_1_b,
                0x10: answer_4_1_b,
                0x11: answer_4_1_b,
                0x12: answer_scope_edgexx,
                0x13: answer_scope_edgexx,
                0x14: answer_scope_edgexx,
                0x15: answer_scope_edgexx,
                0x16: answer_scope_edgexx,
                0x17: answer_scope_edgexx,
                0x18: answer_scope_edgexx,
                0x19: answer_scope_edgexx,
                0x20: answer_scope_edgexx,
                0x21: answer_scope_edgexx,
                0x22: answer_scope_edgexx,
                0x23: answer_scope_edgexx,
                0x24: answer_scope_edgexx,
                0x25: answer_scope_edgexx,
                0x26: answer_scope_edgexx,
                0x27: answer_scope_edgexx,
                0x28: answer_scope_edgexx,
                0x29: answer_scope_edgexx,
                0x30: answer_scope_edgexx,
                0x31: answer_scope_edgexx,
                0x32: answer_scope_edgexx,
                0x33: answer_scope_edgexx,
                0x34: answer_scope_edgexx,
                0x35: answer_scope_edgexx,
                0x36: answer_scope_edgexx,
                0x37: answer_scope_edgexx,
                0x38: answer_scope_edgexx,
                0x39: answer_scope_edgexx,
                0x40: answer_scope_edgexx,
                0x41: answer_scope_edgexx,
                0x42: answer_scope_edgexx,
                0x43: answer_scope_edgexx,
                0x44: answer_scope_edgexx,
                0x45: answer_scope_edgexx,
                0x46: answer_scope_edgexx,
                0x47: answer_scope_edgexx,
                0x48: answer_scope_edgexx,
                0x49: answer_scope_edgexx,
                0x50: answer_scope_edgexx,
                0x51: answer_4_1_b,
                0x52: answer_color,
                0x53: answer_4_1_b,
                0x54: answer_color,
                0x55: answer_4_1_b,
                0x56: answer_4_1_b_1,
                0x57: answer_4_2_b_1,
                0x58: answer_4_2_b_0_1,
                0x59: answer_4_1_b,
                0x60: answer_4_1_b_1,
                0x61: answer_4_1_b_28,
                0x62: answer_4_1_b,
                0x63: answer_4_1_b,
                0x64: answer_4_1_b,
                0x65: answer_4_1_b,
                0x66: answer_4_1_b,
                0x67: answer_color,
                0x68: answer_4_1_b,
                0x69: answer_4_1_b,
                0x70: answer_4_1_b,
                0x71: answer_color,
                0x72: answer_color,
                0x73: answer_4_1_b,
                0x74: answer_4_1_b,
                0x75: answer_4_1_b,
                0x76: answer_4_1_b,
                0x77: answer_4_1_b,
                0x78: answer_4_1_b,
                0x79: answer_4_1_b,
                0x80: answer_4_1_b,
                0x81: answer_4_1_b_1,
                0x82: answer_4_1_b,
                0x83: answer_4_1_b,
                0x84: answer_4_1_b,
                0x85: answer_4_1_b,
                0x86: answer_4_1_b,
                0x87: answer_4_1_b,
                0x88: answer_4_1_b,
                0x89: answer_4_1_b,
                0x90: answer_4_2_b_0_1,
                0x91: answer_4_1_b,
                0x92: answer_4_1_b,
                0x93: answer_2_1_b,
                }

# answer civ-commands == 0y1a06 or 0x1a07
answer_1a67 = { 0x06: answer_data_mode,
              0x07: answer_2_1_b,
                }
# answer civ-commands == 27 (0x1b)
answer_1b = {0x00: answer_tone_frequency,
            0x01: answer_tone_frequency
            }

# answer civ-commands == 28 (0x1c)
answer_1c = {0x00: answer_2_1_b,
            0x01: answer_2_1_b,
            0x02: answer_2_1_b,
            0x03: answer_frequency,
            0x04: answer_2_1_b
            }

# answer civ-commands == 30 (0x1e)
answer_1e = {0x00: answer_2_1_b,
            0x01: answer_band_edge1,
            0x02: answer_2_1_b,
            0x03: answer_band_edge1,
            }

# answer civ-commands == 33 (0x121
answer_21 = {0x00: answer_rit,
            0x01: answer_2_1_b,
            0x02: answer_2_1_b,
            }

# answer civ-commands == 39 (0x27)
answer_27 = {0x00: answer_nop,
            0x10: answer_2_1_b,
            0x11: answer_2_1_b,
            0x12: answer_2_1_b,
            0x13: answer_2_1_b,
            0x14: answer_2_2_b_0_1,
            0x15: answer_scope_span,
            0x16: answer_2_2_b_1_1,
            0x17: answer_2_2_b_0_1,
            0x19: answer_scope_reference_level,
            0x1a: answer_2_2_b_0_1,
            0x1b: answer_2_1_b,
            0x1c: answer_2_1_b,
            0x1d: answer_2_2_b_0_1,
            0x1e: answer_scope_edge00,
            }

answer_rest = {0x25: answer_frequency_sel,
              0x26: answer_mode_data_filter,
              }