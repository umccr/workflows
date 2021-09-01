# DRAGEN Workflows

- [DRAGEN Workflows](#dragen-workflows)
  - [Reference Hash Tables](#reference-hash-tables)
    - [hg38](#hg38)
    - [GRCh37](#grch37)
  - [Alignment and FASTQ Input](#alignment-and-fastq-input)

## Reference Hash Tables

### hg38

- hg38 FASTA matches that from [1000 Genomes][1000Genomes].  
  * One can also download the reference from [this s3 bucket][public_dragen_bucket]
  (see [this DRAGEN issue][genome_match_confirmation_issue].
- We take the hashtable from [the public dragen references list][public_dragen_references] (hg38 / altaware / cnv / anchored / v8)
- We then extract the tarbomb and place it in a compressed tar with the folder of the same name using a CWLTool  
- Built using command below in the "development" project
  * wfl id: `wfl.2e690932bedc4204b2bcb697bb249207`
  * wfl version: `1.0.0`
  * wfl run id: `wfr.3bf2bc688d0d442489cadfcdb2bf9842`  
  * Input body:
    
    <details>
    
    <summary>Click to expand!</summary>    

    ```json
    {
        "name": "create-dragen-v8-hg38-altaware-cnv-anchored-reference",
        "input": {
          "output_directory": "hg38-v8-altaware-cnv-anchored",
          "reference_tar": {
            "class": "File",
            "location": "https://s3.amazonaws.com/use1-prd-seq-hub-appdata/Edico_v8/hg38_altaware-cnv-anchored.v8.tar"
          }
        },
        "engineParameters": {
            "outputDirectory": "gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/"
        }
    }
    ```
    
    </details>
  
  * Outputs body:
    <details>
    
    <summary>Click to expand!</summary>
    
    ```json
    {
      "output_compressed_reference_tar": {
        "basename": "hg38-v8-altaware-cnv-anchored.tar.gz",
        "class": "File",
        "http://commonwl.org/cwltool#generation": 0,
        "location": "gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/hg38-v8-altaware-cnv-anchored.tar.gz",
        "nameext": ".gz",
        "nameroot": "hg38-v8-altaware-cnv-anchored.tar",
        "size": 7664401964
      }
    }
    ```
  
    </details>

  * Tarball entries: `gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/hg38-v8-altaware-cnv-anchored.tar.gz`
    
    ```
    $ gds-view --gds-path gds://development/reference-data/dragen_hash_tables/v8/hg38/altaware-cnv-anchored/hg38-v8-altaware-cnv-anchored.tar.gz --to-stdout | tar -tzf -
    ```  
  
    <details>
    <summary>Click to expand!</summary>
    
    ```text
    hg38-v8-altaware-cnv-anchored/
    ├──appVersion.log
    ├──streaming_log.csv
    ├──reference.bin
    ├──ref_index.bin
    ├──repeat_mask.bin
    ├──str_table.bin
    ├──hash_table.cmp
    ├──hash_table_stats.txt
    ├──hash_table.cfg.bin
    ├──hash_table.cfg
    ├──kmer_cnv.bin
    ├──.time_metrics.csv
    ├──replay.json
    └──anchored_rna/
       ├──reference.bin
       ├──ref_index.bin
       ├──repeat_mask.bin
       ├──str_table.bin
       ├──hash_table.cmp
       ├──hash_table_stats.txt
       ├──hash_table.cfg.bin
       └──hash_table.cfg
    ```
    </details>

    

### GRCh37

- Built using command below in the "development" project
  * wfl id: `wfl.2e690932bedc4204b2bcb697bb249207`
  * wfl version: `1.0.0`
  * wfl run id: `wfr.f0f2f6f602e54d3ebcbc1837d1fc7074`  
  * Input body:
    
    <details>
    
    <summary>Click to expand!</summary>    
    
    ```json
    {
        "name": "create-dragen-v8-GRCh37-cnv-anchored-reference",
        "input": {
          "output_directory": "GRCh37-v8-cnv-anchored",
          "reference_tar": {
            "class": "File",
            "location": "https://s3.amazonaws.com/use1-prd-seq-hub-appdata/Edico_v8/GRCh37-cnv-anchored.v8.tar"
          }
        },
        "engineParameters": {
            "outputDirectory": "gds://development/reference-data/dragen_hash_tables/v8/GRCh37/GRCh37-cnv-anchored/"
        }
    }
    ```
    
    </details>    

  * Outputs body:
    
    <details>
    
    <summary>Click to expand!</summary>    

    ```json
    {
      "output_compressed_reference_tar": {
        "basename": "GRCh37-v8-cnv-anchored.tar.gz",
        "class": "File",
        "http://commonwl.org/cwltool#generation": 0,
        "location": "gds://development/reference-data/dragen_hash_tables/v8/GRCh37/GRCh37-cnv-anchored/GRCh37-v8-cnv-anchored.tar.gz",
        "nameext": ".gz",
        "nameroot": "GRCh37-v8-cnv-anchored.tar",
        "size": 7016023117
      }
    }
    ```

    </details>    

  * Tarball entries:
  
    ```
    $ gds-view --gds-path gds://development/reference-data/dragen_hash_tables/v8/GRCh37/GRCh37-cnv-anchored/GRCh37-v8-cnv-anchored.tar.gz --to-stdout | tar -tzf -
    ```
  
    <details>
  
    <summary>Click to expand!</summary>
  
    ```text
    GRCh37-v8-cnv-anchored/
    ├── appVersion.log
    ├── streaming_log.csv
    ├── reference.bin
    ├── ref_index.bin
    ├── repeat_mask.bin
    ├── str_table.bin
    ├── hash_table.cmp
    ├── hash_table_stats.txt
    ├── hash_table.cfg.bin
    ├── hash_table.cfg
    ├── kmer_cnv.bin
    ├── .time_metrics.csv
    ├── replay.json
    └── anchored_rna/
        ├── reference.bin
        ├── ref_index.bin
        ├── repeat_mask.bin
        ├── str_table.bin
        ├── hash_table.cmp
        ├── hash_table_stats.txt
        ├── hash_table.cfg.bin
        └── hash_table.cfg
    ```
  
    </details>    

\# TODO - check GRCh37 download link
- GRCh37 FASTA downloaded from link in Hartwig [GRIDSS-PURPLE-LINX](https://github.com/hartwigmedical/gridss-purple-linx/blob/47e274459ee8ac760196f6c2ed753c2a83d230fb/README.md) repo.
  - md5sum: `be672f01428605881b2ec450d8089a62  Homo_sapiens.GRCh37.GATK.illumina.fasta`
  - Contains chromosomes 1-22, X, Y, MT. Their md5sums are identical to the
    main chromosomes in the `human_g1k_v37.fasta.gz`
    [reference](ftp://gsapubftp-anonymous:none@ftp.broadinstitute.org/bundle/b37/) used in bcbio (except chr3 for some reason). The GL contigs are also
    discarded.
  

## Alignment and FASTQ Input

The alignment and wgs qc must be done 'per-sample'.  
This means that the output folder includes a single bam and somalier barcode call. 

Here is an example run input / output of the dragen wgs qc workflow:  

### Input json

<details>

<summary>Click to expand!</summary>

```json
{
    "name": "dragen-wgs-test-run",
    "input": {
        "fastq_list_rows": [
            {
                "rgid": "GTGTCGGA.GCTTGCGC.1",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 1,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.2",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 2,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.3",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 3,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.4",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 4,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R2_001.fastq.gz"
                }
            }
        ],
        "output_file_prefix": "MDX200237_L2100008",
        "output_directory": "MDX200237_L2100008",
        "reference_tar": {
            "class": "File",
            "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz"
        }
    },
    "engineParameters": {
        "outputSetting": "leave"
    }
}
```

</details>

### Output json

<details>

<summary>Click to expand! </summary>

\# TODO
```json

```

</details>

## Somatic Calling

Uses similar schema to the germline caller with the additional parameter `tumor_fastq_list_rows`,  
while `fastq_list_rows` represents the 'normal' sample.  

Here's an example input json:

### Input json

<details>

<summary>Click to expand!</summary>

```json
{
    "name": "dragen-somatic-test-run",
    "input": {
        "fastq_list_rows": [
            {
                "rgid": "ACACTAAG.ATCCATAT.1",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 1,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L001_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L001_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "ACACTAAG.ATCCATAT.2",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 2,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L002_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L002_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "ACACTAAG.ATCCATAT.3",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 3,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L003_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L003_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "ACACTAAG.ATCCATAT.4",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 4,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L004_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L004_R2_001.fastq.gz"
                }
            }
        ],
        "tumor_fastq_list_rows": [
            {
                "rgid": "GTGTCGGA.GCTTGCGC.1",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 1,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.2",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 2,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.3",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 3,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.4",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 4,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R2_001.fastq.gz"
                }
            }
        ],
        "output_file_prefix": "MDX200237_L2100008",
        "output_directory": "MDX200237_L2100008",
        "enable_map_align_output": true,
        "enable_duplicate_marking": true,
        "enable_sv": true,
        "reference_tar": {
            "class": "File",
            "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz"
        }
    },
    "engineParameters": {
        "outputSetting": "leave"
    }
}
```

</details>

### Output json \# TODO

<details>

<summary>Click to expand!</summary>

```json
```

</details>

## Other useful links

### Hash table builder (v3.7.5) \# TODO

* CWL tool definition
* CWL tool documentation

### Germline workflow (v3.7.5) \# TODO

* CWL tool definition
* CWL tool documentation

* CWL workflow definition
* CWL workflow documentation

### Somatic workflow (v3.7.5) \# TODO

* CWL tool definition
* CWL tool documentation

* CWL workflow definition
* CWL workflow documentation


[1000Genomes]: http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/
[dragen_tutorial]: https://sapac.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/FrontPages/DRAGENBioITPlatform.htm
[public_dragen_bucket]: https://s3.amazonaws.com/stratus-documentation-us-east-1-public/dragen/reference/Homo_sapiens/hg38.fa
[genome_match_confirmation_issue]: https://github.com/umccr-illumina/dragen/issues/8